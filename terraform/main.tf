resource "aws_vpc" "vpc" {
  cidr_block           = "192.168.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

data "aws_availability_zones" "az_available" {
  state                  = "available"
  all_availability_zones = true
}

resource "aws_subnet" "public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.168.${64 * count.index}.0/18"
  availability_zone       = data.aws_availability_zones.az_available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_subnet" "private_subnet" {
  count             = 2
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "192.168.${64 * count.index + 128}.0/18"
  availability_zone = data.aws_availability_zones.az_available.names[count.index]

  tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_eip" "eip" {
  count  = length(aws_subnet.public_subnet)
  domain = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  count         = length(aws_subnet.public_subnet)
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  depends_on = [aws_internet_gateway.igw]
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "private_route_table" {
  count  = length(aws_nat_gateway.ngw)
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw[count.index].id
  }
}


resource "aws_route_table_association" "public_subnet_route_association" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_route_association" {
  count          = length(aws_subnet.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}

resource "aws_security_group" "control_plane_sg" {
  name   = "${var.app_name}-sg"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_iam_role" "eks_cluster_role" {
  name                  = "${var.app_name}-eks-cluster-role"
  force_detach_policies = true

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

# resource "aws_iam_role" "eks_node_group_role" {
#   name = "${var.app_name}-eks-node-group-role"
#   force_detach_policies = true

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action    = "sts:AssumeRole"
#       Effect    = "Allow"
#       Principal = {
#         Service = "ec2.amazonaws.com"
#       }
#     }]
#   })
# }

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
#   role       = aws_iam_role.eks_node_group_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
# }

# resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
#   role       = aws_iam_role.eks_node_group_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
# }

# resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
#   role       = aws_iam_role.eks_node_group_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
# }

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.app_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.32"

  access_config {
    authentication_mode = "API"
  }

  vpc_config {
    subnet_ids              = concat([for subnet in aws_subnet.public_subnet : subnet.id], [for subnet in aws_subnet.private_subnet : subnet.id])
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy]
}

resource "aws_eks_access_entry" "admin_access" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = var.admin_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin_access_policy" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  principal_arn = var.admin_arn

  access_scope {
    type = "cluster"
  }
}

# module "auth_db" {
#   source            = "./modules/database"
#   app_name          = var.auth.app_name
#   vpc_id            = aws_vpc.vpc.id
#   subnet_ids        = [for subnet in aws_subnet.public_subnet : subnet.id]
#   db_username       = var.auth.db_username
#   db_password       = var.auth.db_password
#   db_port           = var.auth.db_port
#   db_engine         = var.auth.db_engine
#   db_engine_version = var.auth.db_engine_version
# }

# module "payment_db" {
#   source            = "./modules/database"
#   app_name          = var.payment.app_name
#   vpc_id            = aws_vpc.vpc.id
#   subnet_ids        = [for subnet in aws_subnet.public_subnet : subnet.id]
#   db_username       = var.payment.db_username
#   db_password       = var.payment.db_password
#   db_port           = var.payment.db_port
#   db_engine         = var.payment.db_engine
#   db_engine_version = var.payment.db_engine_version
# }

# module "course_db" {
#   source            = "./modules/database"
#   app_name          = var.course.app_name
#   vpc_id            = aws_vpc.vpc.id
#   subnet_ids        = [for subnet in aws_subnet.public_subnet : subnet.id]
#   db_username       = var.course.db_username
#   db_password       = var.course.db_password
#   db_port           = var.course.db_port
#   db_engine         = var.course.db_engine
#   db_engine_version = var.course.db_engine_version
# }
