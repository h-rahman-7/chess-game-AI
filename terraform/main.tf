# This module (row 4) includes the configuration setup for my VPC, subnets (public & private), IGW and routing info
# The additional rows allow dynamic/flexible collobaration - i.e. colleague may want to use diff sandbox configurations

module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = "10.0.0.0/16"
  vpc_name            = "cg-vpc"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  availability_zones  = ["us-east-1a", "us-east-1b"]
}

module "security_group" {
  source  = "./modules/security-group"
  sg_name = "cg-ecs-sg"
  vpc_id  = module.vpc.vpc_id
}

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

module "ecs" {
  source             = "./modules/ecs"
  cluster_name       = "cg-ecs-cluster"
  task_family        = "cg-task"
  task_cpu           = "2048"
  task_memory        = "6144"
  repository_name    = "chess-game" # Name of your ECR repository
  #image_tag          = "latest"    # Optional, defaults to "latest"
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

module "route53" {
  source = "/c/CoderCo/chess-game-ai/terraform/modules/route53"
  zone_name    = "habibur-rahman.com"
  record_name  = "cgai.habibur-rahman.com"
  ttl          = 300
  alb_dns_name = module.alb.alb_dns_name
}
