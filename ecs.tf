// セキュリティグループ
resource "aws_security_group" "ecs_backend_sg" {
  vpc_id = aws_vpc.practice.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
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

// ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "terraform-cluster"
}

// ECS Service
resource "aws_ecs_service" "nginx_service" {
  name            = "terraform-nginx-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_nginx_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.ecs_subnet_public_1a.id, aws_subnet.ecs_subnet_public_1c.id]
    security_groups = [aws_security_group.ecs_backend_sg.id]
    assign_public_ip = true
  }
}

// nginxのタスク定義
resource "aws_ecs_task_definition" "ecs_nginx_task_definition" {
  family = "terraform-nginx-task"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu                      = 256
  memory                   = 512

// nginxのデフォルトイメージをECRから取得
  container_definitions = jsonencode([
    {
      name = "nginx"
      image     = "public.ecr.aws/nginx/nginx:mainline-alpine"
      portMappings = [
        {
          containerPort = 80
          hostPort = 80
        }
      ]
    }
  ])

  execution_role_arn = aws_iam_role.ecs_ecs_task_execution_role.arn
}

// IAM
resource "aws_iam_role" "ecs_ecs_task_execution_role" {
  name = "terraform-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "terraform-ecs-task-execution-role"
  }
}
