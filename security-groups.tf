# VPC Endpoint Security Group
resource "aws_security_group" "vpc_endpoint" {
  name   = "${local.prefix}-vpce-sg"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  tags = local.common_tags
}


# AWS Fargate Security Group
resource "aws_security_group" "fargate_task" {
  name   = "${local.service_name}-fargate-task"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port   = local.service_port
    to_port     = local.service_port
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(
  local.common_tags,
  {
    Name = local.service_name
  }
  )
}

resource "aws_security_group" "db-sg" {
  name = "db-sg"
  vpc_id      = module.vpc.vpc_id
  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"

    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
}