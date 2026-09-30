# resource "aws_ecs_cluster" "this" {
#   name = "main-ecs-cluster"
# }

# resource "aws_ecs_task_definition" "app" {
#   family                   = "app"
#   requires_compatibilities = ["FARGATE"]
#   network_mode             = "awsvpc"
#   cpu                      = "256"
#   memory                   = "512"
#   execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
#   container_definitions = jsonencode([
#     {
#       name = "app"
#       #   image     = "public.ecr.aws/nginx/nginx:trixie-perl"
#       image     = "${var.ecr_repository_url}:${var.image_tag}"
#       cpu       = 256
#       memory    = 512
#       essential = true
#       portMappings = [
#         {
#           containerPort = 80
#           protocol      = "tcp"
#           hostPort      = 80
#         }
#       ]
#     }
#   ])
# }

# resource "aws_iam_role" "ecs_task_execution_role" {
#   name               = "ecsTaskExecutionRole_new"
#   assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
# }

# data "aws_iam_policy_document" "assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRole"]
#     principals {
#       type        = "Service"
#       identifiers = ["ecs-tasks.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
#   role       = aws_iam_role.ecs_task_execution_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }

# resource "aws_ecs_service" "this" {
#   name            = "app-service"
#   cluster         = aws_ecs_cluster.this.id
#   task_definition = aws_ecs_task_definition.app.arn
#   launch_type     = "FARGATE"
#   desired_count   = 2
#   network_configuration {
#     subnets          = var.private_subnets
#     assign_public_ip = true
#     security_groups  = [var.sg_ecs]
#   }
#   load_balancer {
#     target_group_arn = var.alb_target_group
#     container_name   = "app"
#     container_port   = 80
#   }
#   depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role_policy]
# }
resource "aws_ecs_cluster" "this" {
  name = "main-ecs-cluster"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole_new"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "public.ecr.aws/nginx/nginx:latest"
      cpu       = 256
      memory    = 512
      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "this" {
  name            = "app-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = 2

  network_configuration {
    subnets          = var.private_subnets
    assign_public_ip = true
    security_groups  = [var.sg_ecs]
  }

  load_balancer {
    target_group_arn = var.alb_target_group
    container_name   = "app"
    container_port   = 80
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_task_execution_role_policy
  ]
}