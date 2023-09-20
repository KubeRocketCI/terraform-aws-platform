module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = var.platform_name

  create_vpc = true

  cidr            = var.platform_cidr
  azs             = var.subnet_azs
  private_subnets = var.private_cidrs
  public_subnets  = var.public_cidrs

  map_public_ip_on_launch = false
  enable_dns_hostnames    = true
  enable_dns_support      = true
  enable_nat_gateway      = true
  single_nat_gateway      = true
  one_nat_gateway_per_az  = false

  tags = var.tags
}
