resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db_subnet_group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "db_subnet_group"
  }
}