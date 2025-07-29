resource "aws_eks_cluster" "eks_cluster" {
  name     = var.app_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.32"

  bootstrap_self_managed_addons = false

  access_config {
    authentication_mode = "API"
  }

  vpc_config {
    subnet_ids              = concat([for subnet in aws_subnet.public_subnet : subnet.id], [for subnet in aws_subnet.private_subnet : subnet.id])
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  compute_config {
    enabled       = true
    node_pools    = ["general-purpose"]
    node_role_arn = aws_iam_role.eks_node_group_role.arn
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
  }

  storage_config {
    block_storage {
      enabled = true
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSComputePolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSBlockStoragePolicyy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSLoadBalancingPolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSNetworkingPolicy,
  ]
}


# resource "aws_eks_node_group" "node_group" {
#   cluster_name    = aws_eks_cluster.eks_cluster.name
#   node_group_name = "${var.app_name}-node-group"
#   node_role_arn   = aws_iam_role.eks_node_group_role.arn
#   subnet_ids      = concat([for subnet in aws_subnet.public_subnet : subnet.id], [for subnet in aws_subnet.private_subnet : subnet.id])

#   scaling_config {
#     desired_size = 1
#     max_size     = 3
#     min_size     = 1
#   }

#   instance_types = ["t3.medium"]

#   depends_on = [
#     aws_iam_role_policy_attachment.eks_node_group_AmazonEKS_CNI_Policy,
#     aws_iam_role_policy_attachment.eks_node_group_AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.eks_node_group_AmazonEC2ContainerRegistryReadOnly,
#   ]
# }

module "auth_db" {
  source            = "./modules/database"
  app_name          = var.auth.app_name
  vpc_id            = aws_vpc.vpc.id
  subnet_ids        = [for subnet in aws_subnet.public_subnet : subnet.id]
  db_username       = var.auth.db_username
  db_password       = var.auth.db_password
  db_port           = var.auth.db_port
  db_engine         = var.auth.db_engine
  db_engine_version = var.auth.db_engine_version
}

module "payment_db" {
  source            = "./modules/database"
  app_name          = var.payment.app_name
  vpc_id            = aws_vpc.vpc.id
  subnet_ids        = [for subnet in aws_subnet.public_subnet : subnet.id]
  db_username       = var.payment.db_username
  db_password       = var.payment.db_password
  db_port           = var.payment.db_port
  db_engine         = var.payment.db_engine
  db_engine_version = var.payment.db_engine_version
}

module "course_db" {
  source            = "./modules/database"
  app_name          = var.course.app_name
  vpc_id            = aws_vpc.vpc.id
  subnet_ids        = [for subnet in aws_subnet.public_subnet : subnet.id]
  db_username       = var.course.db_username
  db_password       = var.course.db_password
  db_port           = var.course.db_port
  db_engine         = var.course.db_engine
  db_engine_version = var.course.db_engine_version
}
