module "vpc" {
  source  = "shamimice03/vpc/aws"
  version = "1.0.6"
  cidr    = var.vpc_cidr

  azs                = var.azs
  public_subnet_cidr = var.public_subnet_cidr

  enable_dns_hostnames      = true
  enable_dns_support        = true
  enable_single_nat_gateway = var.enable_single_nat_gateway

  tags = merge(local.tags, {
    "Name" = "${local.tags.Name}_vpc"
  })
}


