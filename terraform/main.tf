resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

data "aws_availability_zones" "az_available" {
  state                  = "available"
  all_availability_zones = true
}

resource "aws_subnet" "public_subnet" {
  count                   = length(data.aws_availability_zones.az_available.names)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.${10 + count.index}.0/24"
  availability_zone       = data.aws_availability_zones.az_available.names[count.index]
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id     = aws_vpc.vpc.id
  depends_on = [aws_vpc.vpc]
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "subnet_route_table_association" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

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
