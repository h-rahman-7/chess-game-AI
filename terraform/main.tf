# This module (row 4) includes the configuration setup for my VPC, subnets (public & private), IGW and routing info
# The additional rows allow dynamic/flexible collobaration - i.e. colleague may want to use diff sandbox configurations

# VPC Module
module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = "10.0.0.0/16"
  vpc_name            = "cg-vpc"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  availability_zones  = ["us-east-1a", "us-east-1b"]
}

resource "aws_flow_log" "vpc_flow_logs" {
  vpc_id                 = module.vpc.vpc_id
  traffic_type           = "ALL"
  log_destination        = aws_cloudwatch_log_group.flow_logs.arn
  log_destination_type   = "cloud-watch-logs"
  iam_role_arn           = aws_iam_role.flow_logs_role.arn
}

resource "aws_kms_key" "chess_app_key" {
  description             = "KMS key for the Chess App"
  enable_key_rotation     = true # Enable automatic key rotation
  deletion_window_in_days = 30   # Optional, specifies the waiting period before deletion

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Id": "key-default-1",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    }
  ]
}
EOT

  tags = {
    Name        = "chess-app-kms-key"
    Environment = "production"
  }
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "/aws/vpc/flow-logs"
  kms_key_id = aws_kms_key.chess_app_key.id
  retention_in_days = 365
}

resource "aws_iam_role" "flow_logs_role" {
  name = "vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "flow_logs_policy" {
  name       = "flow-logs-policy-attach"
  roles      = [aws_iam_role.flow_logs_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2FlowLogsRole"
}

# Security Group Module
module "security_group" {
  source  = "./modules/security-group"
  sg_name = "cg-ecs-sg"
  vpc_id  = module.vpc.vpc_id
}

# ALB Module
module "alb" {
  source            = "./modules/alb"
  alb_name          = "cg-app-alb"
  security_group_id = module.security_group.sg_id
  subnet_ids        = module.vpc.public_subnets
  target_group_name = "cg-target-group"
  target_port       = 3002
  vpc_id            = module.vpc.vpc_id
  certificate_arn   = "arn:aws:acm:us-east-1:713881828888:certificate/2c9a27e7-a2dd-4a9b-bf4d-f31c8ca34ef9"
}

# ECS Module
module "ecs" {
  source             = "./modules/ecs"
  cluster_name       = "cg-ecs-cluster"
  task_family        = "cg-task"
  task_cpu           = "2048"
  task_memory        = "6144"
  repository_name    = "chess-game"
  container_name     = "cg-container"
  container_image    = "713881828888.dkr.ecr.us-east-1.amazonaws.com/chess-game:latest"
  container_port     = 3002
  service_name       = "my-cg-service"
  desired_count      = 1
  subnet_ids         = module.vpc.public_subnets
  security_group_ids = [module.security_group.sg_id]
  target_group_arn   = module.alb.target_group_arn
  listener_http_arn  = module.alb.http_listener
  listener_https_arn = module.alb.https_listener

  create_iam_role    = false
  execution_role_arn = "arn:aws:iam::713881828888:role/ecs-task-execution-role"
  task_role_arn      = "arn:aws:iam::713881828888:role/ecs-task-execution-role"
  iam_role_name      = "ecsTaskExecutionRole"
}

# WAF Configuration
resource "aws_wafv2_web_acl" "cgai_waf" {
  name        = "cgai-waf"
  scope       = "REGIONAL" # For ALB
  description = "WAF for ALB"

  default_action {
    allow {}
  }

  rule {
    name     = "block-bad-requests"
    priority = 1
    action {
      block {}
    }
    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
      }
    }
    visibility_config {
      sampled_requests_enabled    = true
      cloudwatch_metrics_enabled  = true
      metric_name                 = "blockBadRequests"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "webACL"
    sampled_requests_enabled   = true
  }
}

# Associate WAF with ALB
resource "aws_wafv2_web_acl_association" "cgai_waf_association" {
  resource_arn = module.alb.alb_arn # Replace with the ALB ARN output from your module
  web_acl_arn  = aws_wafv2_web_acl.cgai_waf.arn
}

# Route53 Module
module "route53" {
  source      = "./modules/Route53"
  zone_name   = "habibur-rahman.com"
  record_name = "cgai.habibur-rahman.com"
  ttl         = 300
  alb_dns_name = module.alb.alb_dns_name
}
