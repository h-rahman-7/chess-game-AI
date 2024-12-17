## My application security group
resource "aws_security_group" "cg_sg" {
  name = var.sg_name
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows HTTP from anywhere
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows HTTPS from anywhere
  }

  ingress {
    from_port   = 3002           # Forwarding requests to ECS container
    to_port     = 3002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"           # Allows all outgoing traffic   
    cidr_blocks = ["0.0.0.0/0"]  
  }

  tags = {
    Name = var.sg_name
  }
}
