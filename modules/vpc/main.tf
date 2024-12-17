## My VPC
resource "aws_vpc" "cg_vpc" {
  cidr_block           = var.vpc_cidr   # The size of your network (larger than one below 2^16)
  enable_dns_support   = true            # Helps services find each other using names
  enable_dns_hostnames = true            # Allows human-readable names like "myapp.com"
  tags = {
    Name = var.vpc_name                      # The name/tag you give your VPC
  }
}

## My subnets
resource "aws_subnet" "cg_public_sn" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.cg_vpc.id                        # Attach this public subnet to your VPC
  cidr_block              = var.public_subnet_cidrs[count.index]     # A smaller range of IPs (256 addresses 2^8) for public use
  map_public_ip_on_launch = true                                     # Public IPs for resources in this subnet
  availability_zone       = var.availability_zones[count.index]      # Place this subnet in a specific AWS data center
  tags = {
    Name = "${var.vpc_name}-public-${count.index + 1}"               # Name the subnet
  }
}

resource "aws_subnet" "cg_private_sn" {
  vpc_id            = aws_vpc.cg_vpc.id
  cidr_block        = "10.0.3.0/24"                                  # Another range of IPs for private use
  availability_zone = "us-east-1b"
  tags = {
    Name = "cg-private-sn"
  }
}

## My internet gateway
resource "aws_internet_gateway" "cg_igw" {
  vpc_id = aws_vpc.cg_vpc.id
  tags = {
    Name = "$(var.vpc_name)-igw"
  }
}

## My route table
resource "aws_route_table" "cg_rt" {
  vpc_id = aws_vpc.cg_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cg_igw.id
  }

  tags = {
    Name = "${var.vpc_name}}-rt"
  }
}

## My route table association
resource "aws_route_table_association" "cg_subnet_rt_assoc" {
  count = length(aws_subnet.cg_public_sn)
  subnet_id      = aws_subnet.cg_public_sn[count.index].id
  route_table_id = aws_route_table.cg_rt.id
}

## My ACM certificate
resource "aws_acm_certificate" "cert" {
  domain_name       = "ecs.habibur-rahman.com"  
  validation_method = "DNS"                      
  tags = {
    Name = "ecs-cert"
  }
}


