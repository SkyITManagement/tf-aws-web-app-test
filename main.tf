data "terraform_remote_state" "rds" {
  backend = "local"
  config = {
    path = var.rds_terraform_state_path
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_ecr_repository" "app" {
  name                 = var.app_ecr_repo_name
  image_tag_mutability = "MUTABLE"
}

resource "aws_security_group" "alb" {
  name   = "webapp-alb-sg"
  vpc_id = data.aws_vpc.default.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs" {
  name   = "webapp-ecs-sg"
  vpc_id = data.aws_vpc.default.id
  ingress {
    from_port       = var.app_container_port
    to_port         = var.app_container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "app" {
  name               = "webapp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.default.ids
}

resource "aws_lb_target_group" "app" {
  name     = "webapp-tg"
  port     = var.app_container_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  health_check {
    path     = "/"
    protocol = "HTTP"
    matcher  = "200-399"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_iam_role" "ecs_exec" {
  name = "webapp-ecs-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = { Service = "ecs-tasks.amazonaws.com" },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_exec_policy" {
  role       = aws_iam_role.ecs_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task" {
  name = "webapp-ecs-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = { Service = "ecs-tasks.amazonaws.com" },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_ecs_cluster" "app" {
  name = "webapp-cluster"
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/webapp"
  retention_in_days = 14
}

resource "aws_ecs_task_definition" "app" {
  family                   = "webapp-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.task_cpu)
  memory                   = tostring(var.task_memory)
  execution_role_arn       = aws_iam_role.ecs_exec.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  container_definitions = jsonencode([
    {
      name      = "webapp"
      image     = "${aws_ecr_repository.app.repository_url}:${var.app_image_tag}"
      cpu       = var.task_cpu
      memory    = var.task_memory
      essential = true
      portMappings = [
        {
          containerPort = var.app_container_port
          hostPort      = var.app_container_port
          protocol      = "tcp"
        }
      ]
      environment = concat(
        [
          { name = "DB_HOST", value = data.terraform_remote_state.rds.outputs.db_endpoint },
          { name = "DB_PORT", value = tostring(data.terraform_remote_state.rds.outputs.db_port) },
          { name = "DB_NAME", value = data.terraform_remote_state.rds.outputs.db_name },
          { name = "DB_USER", value = data.terraform_remote_state.rds.outputs.db_username }
        ],
        [for k, v in var.container_env : { name = k, value = v }]
      )
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/webapp"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "app" {
  name            = "webapp-service"
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = data.aws_subnets.default.ids
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "webapp"
    container_port   = var.app_container_port
  }
  depends_on = [aws_lb_listener.http]
}

