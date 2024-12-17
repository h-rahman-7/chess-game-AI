output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.cg_vpc.id
}

output "public_subnets" {
  description = "The IDs of the public subnets"
  value       = aws_subnet.cg_public_subnet[*].id
}

output "internet_gateway_id" {
  description = "The ID of the internet gateway"
  value       = aws_internet_gateway.cg_igw.id
}