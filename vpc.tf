module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "${local.prefix}-vpc"
  cidr = local.vpc_cidr
  azs             = ["${local.aws_region}a", "${local.aws_region}b"]
  private_subnets = ["10.0.0.0/24", "10.0.1.0/24"]
  public_subnets  = ["10.0.100.0/24", "10.0.101.0/24"]
  enable_nat_gateway      = false
  single_nat_gateway      = false
  enable_vpn_gateway      = false
  enable_dns_hostnames    = true
  enable_dns_support      = true
  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-vpc"
    }
  )
}