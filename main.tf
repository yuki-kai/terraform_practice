# クラスター
resource "aws_ecs_cluster" "practice" {
  name = "terraform-cluster"
}

# タスク定義
resource "aws_ecs_task_definition" "practice" {
  family                   = "terraform-task"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions = jsonencode([
    {
      name         = "nginx"
      image        = "public.ecr.aws/nginx/nginx:mainline-alpine"
      essential    = true
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = 80
        }
      ]
    }
  ])
}






# タスク実行
data "aws_ecs_task_execution" "practice" {
  cluster         = aws_ecs_cluster.practice.id
  task_definition = aws_ecs_task_definition.practice.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [
      aws_subnet.public_a.id,
      aws_subnet.public_c.id
    ]
    security_groups  = [aws_security_group.practice.id]
    assign_public_ip = true
  }
}

/*
# サービス
resource "aws_ecs_service" "practice" {
  name            = "terraform-service"
  cluster         = aws_ecs_cluster.practice.id
  task_definition = aws_ecs_task_definition.practice.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [
      aws_subnet.public_a.id,
      aws_subnet.public_c.id
    ]
    security_groups  = [aws_security_group.practice.id]
    assign_public_ip = true
  }
  lifecycle {
    ignore_changes = [desired_count]
  }
}
*/



# セキュリティグループ
resource "aws_security_group" "practice" {
  name   = "terraform-ecs-sg"
  vpc_id = aws_vpc.practice.id
}
resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.practice.cidr_block]
  security_group_id = aws_security_group.practice.id
}
