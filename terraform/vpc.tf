resource "aws_vpc" "vpc" {
  cidr_block           = "172.32.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

data "aws_availability_zones" "az_available" {
  state                  = "available"
  all_availability_zones = true
}

resource "aws_subnet" "public_subnet" {
  for_each = toset(data.aws_availability_zones.az_available.names)
  vpc_id   = aws_vpc.vpc.id
  cidr_block = cidrsubnet(
    aws_vpc.vpc.cidr_block,
    4,
    index(data.aws_availability_zones.az_available.names, each.value)
  )
  availability_zone       = each.value
  map_public_ip_on_launch = true

  #   tags = {
  #     "kubernetes.io/role/elb" = 1
  #   }
}

resource "aws_subnet" "private_subnet" {
  for_each = toset(data.aws_availability_zones.az_available.names)
  vpc_id   = aws_vpc.vpc.id
  cidr_block = cidrsubnet(
    aws_vpc.vpc.cidr_block,
    4,
    length(data.aws_availability_zones.az_available.names) + index(data.aws_availability_zones.az_available.names, each.value)
  )
  availability_zone = each.value

  #   tags = {
  #     "kubernetes.io/role/internal-elb" = 1
  #   }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet[data.aws_availability_zones.az_available.names[0]].id

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

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }
}

resource "aws_route_table_association" "public_subnet_rtb_association" {
  for_each       = aws_subnet.public_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnnet_rtb_association" {
  for_each       = aws_subnet.private_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table.id
}

# resource "aws_security_group" "control_plane_sg" {
#   name   = "${var.app_name}-sg"
#   vpc_id = aws_vpc.vpc.id
# }
