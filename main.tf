terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
  }
}

locals {
  aws_region  = "us-east-1"
  prefix      = "fargate-web"
  common_tags = {
    Project         = local.prefix
    ManagedBy       = "Terraform"
  }
  vpc_cidr = "10.0.0.0/16"
  imagem = "233181867717.dkr.ecr.us-east-1.amazonaws.com/web-ecr:latest"
}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}



locals {
  aws_account_id = data.aws_caller_identity.current.account_id
  service_name = "kubenews"
  service_port = 8080
  
}
# Fargate service
resource "aws_ecs_cluster" "main" {
  name = "${local.prefix}-ecs-cluster"
  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-ecs-cluster"
    }
  )
}

resource "aws_ecs_task_definition" "app" {
  family                   = local.service_name
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  requires_compatibilities = ["FARGATE"]
  container_definitions = <<DEFINITION
  [
    {
      "name": "kubenews",
      "image": "${local.imagem}",
      "environment": ${jsonencode(
        [
          {
          "name": "DB_HOST",
          "value": "${aws_db_instance.rds.address}"
          },
          {
          "name": "DB_DATABASE",
          "value": "postgresdb"
          },
          {
          "name": "DB_USERNAME",
          "value": "postgresuser"
          },
          {
          "name": "DB_PASSWORD",
          "value": "postgrespwd"
          }
        ])},
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${local.service_port},
          "hostPort": ${local.service_port}
        }
      ],
      "cpu": 512,
      "memory": 1024,
      "networkMode": "awsvpc"
      
    }
  ]
  DEFINITION
  execution_role_arn       = aws_iam_role.fargate_execution.arn
  task_role_arn            = aws_iam_role.fargate_task.arn
  tags = merge(
    local.common_tags,
    {
      Name = local.service_name
    }
  )
  depends_on = [aws_db_instance.rds]
}
resource "aws_ecs_service" "app" {
  name            = local.service_name
  cluster         = aws_ecs_cluster.main.name
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = "1"
  launch_type     = "FARGATE"
  network_configuration {
    security_groups = [aws_security_group.fargate_task.id]
    subnets         = module.vpc.private_subnets
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = local.service_name
    container_port   = local.service_port
  }
}

resource "aws_db_instance" "rds" {
  identifier             = "postgresdb"
  db_name                = "postgresdb"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "15.3"
  username               = "postgresuser"
  password               = "postgrespwd"
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  parameter_group_name   = aws_db_parameter_group.dbpg.name
  availability_zone      = "us-east-1a"
  publicly_accessible    = false
  skip_final_snapshot    = true
}