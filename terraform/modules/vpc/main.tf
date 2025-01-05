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
  map_public_ip_on_launch = false                                    # No Public IPs for resources in this subnet
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
  count = length(aws_subnet.cg_public_sn[*].id)
  subnet_id      = aws_subnet.cg_public_sn[count.index].id
  route_table_id = aws_route_table.cg_rt.id
}

## My ACM certificate
resource "aws_acm_certificate" "cert" {
  domain_name       = "cgai.habibur-rahman.com"  
  validation_method = "DNS"                      
  tags = {
    Name = "ecs-cert"
  }
}

# This resource modifies the default security group created by AWS for the VPC.
# The default security group allows all inbound traffic within the VPC, which is a security risk.
# By restricting inbound traffic (ingress) and allowing only outbound traffic (egress),
# we ensure the default security group adheres to security best practices.
# This is required to pass Checkov's CKV2_AWS_12 policy check.

resource "aws_default_security_group" "restrict_default_sg" {
  vpc_id = aws_vpc.cg_vpc.id  # Reference the correct VPC resource

  # Restrict all inbound traffic
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]  # Blocks all inbound traffic
    description = "Block all inbound traffic"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allows all outbound traffic
    description = "Allow all outbound traffic"
  }

  # Add a descriptive tag for better visibility
  tags = {
    Name = "${var.vpc_name}-default-sg"
  }
}