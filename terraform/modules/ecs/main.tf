## My ECS cluster
resource "aws_ecs_cluster" "cg_ecs_cluster" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

## My ECS task definition
resource "aws_ecs_task_definition" "cg_app_td" {
  family                   = var.task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  cpu                      = var.task_cpu
  memory                   = var.task_memory

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      cpu       = 0
      essential = true
      portMappings = [{
        containerPort = var.container_port
        hostPort      = var.container_port
        protocol      = "tcp"
      }]
    }
  ])
}

## My ECS service
resource "aws_ecs_service" "cg_app_service" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.cg_ecs_cluster.id
  task_definition = aws_ecs_task_definition.cg_app_td.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = true
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  deployment_controller {
    type = "ECS"
  }

  depends_on = [var.listener_http_arn, var.listener_https_arn]
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = data.aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}