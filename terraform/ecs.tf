# ## My ECS cluster
# resource "aws_ecs_cluster" "cg_ecs_cluster" {
#   name = "cg-ecs-cluster"

#   setting {
#     name  = "containerInsights"
#     value = "enabled"
#   }
# }

# ## My ECS task definitions for my AI Chess game
# resource "aws_ecs_task_definition" "cg_app_td" {
#   family                   = "cg-app-td"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
#   task_role_arn            = data.aws_iam_role.ecs_task_execution_role.arn
#   cpu                      = "1024"
#   memory                   = "3072"

#   container_definitions = jsonencode([
#     {
#       name      = "cg-container"
#       image     = "713881828888.dkr.ecr.us-east-1.amazonaws.com/chess-game"
#       cpu       = 0
#       essential = true
#       portMappings = [{
#         containerPort = 3002
#         hostPort      = 3002
#         protocol      = "tcp"
#       }]
#     }
#   ])
# }

# ## My ECS service
# resource "aws_ecs_service" "cg_app_service" {
#   name            = "cg-app-service"
#   cluster         = aws_ecs_cluster.cg_ecs_cluster.id
#   task_definition = aws_ecs_task_definition.cg_app_td.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"

#   network_configuration {
#     assign_public_ip = true
#     subnets          = [aws_subnet.cg_public_sn1.id, aws_subnet.cg_public_sn2.id]
#     security_groups  = [aws_security_group.cg_sg.id]  
#     }

#   load_balancer {
#     target_group_arn = aws_lb_target_group.cg_app_lb_tg.arn
#     container_name   = "cg-container"
#     container_port   = 3002
#   }

#   deployment_controller {
#     type = "ECS"
#   }

#   depends_on = [aws_lb_listener.cg_http_listener]
# }

# data "aws_iam_role" "ecs_task_execution_role" {
#   name = "ecs-task-execution-role"
# }

# resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
#   role       = data.aws_iam_role.ecs_task_execution_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }




