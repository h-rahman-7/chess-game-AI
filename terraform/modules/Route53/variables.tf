variable "zone_name" {
  type        = string
  description = "Route53 zone name"
}

variable "record_name" {
  type        = string
  description = "CNAME record name for ALB"
}

variable "ttl" {
  type        = number
  description = "Time to live for the DNS record"
}

variable "alb_dns_name" {
  type        = string
  description = "DNS name of the ALB where the app can be accessed on"
}