# VPC
resource "aws_vpc" "practice" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Terraform"
  }
}

# インターネットゲートウェイ
resource "aws_internet_gateway" "practice" {
  vpc_id = aws_vpc.practice.id
  tags = {
    Name = "Terraform"
  }
}

# サブネット
resource "aws_subnet" "ecs_subnet_public_1a" {
  vpc_id     = aws_vpc.practice.id
  cidr_block = "10.0.0.0/24"
  # サブネットで起動したインスタンスにパブリックIPを自動で割り当てる
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Terraform"
  }
}
resource "aws_subnet" "ecs_subnet_public_1c" {
  vpc_id     = aws_vpc.practice.id
  cidr_block = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "Terraform"
  }
}
resource "aws_subnet" "ecs_subnet_public_1d" {
  vpc_id     = aws_vpc.practice.id
  cidr_block = "10.0.2.0/24"
  availability_zone       = "ap-northeast-1d"
  map_public_ip_on_launch = true
  tags = {
    Name = "Terraform"
  }
}

# ルートテーブル
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.practice.id
  tags = {
    Name = "Terraform"
  }
}

# ルート
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.practice.id
  destination_cidr_block = "0.0.0.0/0"
}

# ルートテーブルの関連付け
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.ecs_subnet_public_1a.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.ecs_subnet_public_1c.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public_d" {
  subnet_id      = aws_subnet.ecs_subnet_public_1d.id
  route_table_id = aws_route_table.public.id
}
