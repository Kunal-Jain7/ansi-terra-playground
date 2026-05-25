locals {
  azs = data.aws_availability_zones.available.names
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "client-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "client-vpc"
  }
}

resource "aws_internet_gateway" "client-igw" {
  vpc_id = aws_vpc.client-vpc.id

  tags = {
    Name = "client-igw"
  }
}

resource "aws_route_table" "client-rt" {
  vpc_id = aws_vpc.client-vpc.id
}

resource "aws_route" "client-route" {
  route_table_id         = aws_route_table.client-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.client-igw.id
}

resource "aws_default_route_table" "client-private-rt" {
  default_route_table_id = aws_vpc.client-vpc.default_route_table_id
}

resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.client-vpc.id
  count                   = length(local.azs)
  cidr_block              = cidrsubnet(aws_vpc.client-vpc.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = local.azs[count.index]
  tags = {
    Name = "client-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id                  = aws_vpc.client-vpc.id
  count                   = length(local.azs)
  cidr_block              = cidrsubnet(aws_vpc.client-vpc.cidr_block, 8, count.index + length(local.azs))
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "client-private-subnet-${count.index + 1}"
  }
}

resource "aws_route_table_association" "public-rt-assoc" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.client-rt.id
}

resource "aws_security_group" "client-sg" {
  name        = "client-sg"
  description = "Security group for client VPC"
  vpc_id      = aws_vpc.client-vpc.id
}

resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65536
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.client-sg.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65536
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.client-sg.id

}

