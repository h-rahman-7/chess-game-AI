## My application security group
resource "aws_security_group" "cg_sg" {
  name = var.sg_name
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows HTTP from anywhere
    description = "Allow public HTTP traffic"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows HTTPS from anywhere
    description = "Allow public HTTPS traffic"
  }

 # Allow public ECS container traffic (if required)
  ingress {
    from_port   = 3002           # Forwarding requests to ECS container
    to_port     = 3002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow ECS container traffic from anywhere
    description = "Allow public ECS traffic"  
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
