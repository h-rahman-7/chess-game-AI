## My application load balancer
resource "aws_lb" "cg_app_lb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }

  access_logs {
    bucket  = "chess-game-terraform-state"
    prefix  = "alb-logs"
    enabled = true
  }
}

## My ALB target group
resource "aws_lb_target_group" "cg_app_lb_tg" {
  name        = var.target_group_name
  target_type = "ip"
  port        = 3002
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
}

## My ALB listener for HTTP redirecting to port 443
resource "aws_lb_listener" "cg_http_listener" {
  load_balancer_arn = aws_lb.cg_app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  # default_action {
  #   type             = "forward"
  #   target_group_arn = aws_lb_target_group.cg_app_lb_tg.arn
  # }  
  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }

}

## My ALB listener for HTTPS forwarding to port 3002
resource "aws_lb_listener" "cg_https_listener" {
  load_balancer_arn = aws_lb.cg_app_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn
 
 ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01" # Enforce TLS 1.2

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cg_app_lb_tg.arn
  }
}

