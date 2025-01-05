## My application security group
resource "aws_security_group" "cg_sg" {
  name = var.sg_name
  vpc_id = var.vpc_id

# Allowing unrestricted access to port 80 (HTTP) is flagged as insecure. Modern best practices enforce HTTPS (port 443) instead of HTTP.
  # ingress {
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]  # Allows HTTP from anywhere
  #   description = "Allow public HTTP traffic"
  # }

# Allowing HTTPS traffic on port 443 
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows HTTPS from anywhere
    description = "Allow public HTTPS traffic"
  }

 # ECS container security group rule
  ingress {
    from_port   = 3002           # Forwarding requests to ECS container
    to_port     = 3002
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"] # Allow traffic only from the ALB
    description = "Allow ECS traffic from ALB subnets"
  }

 # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"           # Allows all outgoing traffic   
    cidr_blocks = ["0.0.0.0/0"]  
    description = "Allow all outbound traffic"
    }

  tags = {
    Name = var.sg_name
  }
}
