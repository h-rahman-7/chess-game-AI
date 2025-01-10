output "alb_arn" {
  description = "The ARN of the Application Load Balancer"
  value       = aws_lb.cg_app_lb.arn 
}

output "alb_url" {
  description = "The URL of the Application Load Balancer"
  value       = aws_lb.cg_app_lb.dns_name
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.cg_app_lb_tg.arn
}

output "http_listener" {
  description = "The ID of the HTTP Listener"
  value       = aws_lb_listener.cg_http_listener.id
}

output "https_listener" {
  description = "The ID of the HTTPS Listener"
  value       = aws_lb_listener.cg_https_listener.id
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.cg_app_lb.dns_name
}