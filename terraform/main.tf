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
