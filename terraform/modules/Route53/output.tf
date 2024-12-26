output "route53_record" {
  description = "The created Route53 CNAME record for ALB"
  value       = aws_route53_record.cgai_cname_record
}