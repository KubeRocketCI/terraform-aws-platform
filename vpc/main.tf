module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.14.0"

  name = var.platform_name

  create_vpc = true

  cidr            = var.platform_cidr
  azs             = var.subnet_azs
  private_subnets = var.private_cidrs
  public_subnets  = var.public_cidrs

  map_public_ip_on_launch    = false
  enable_dns_hostnames       = true
  enable_dns_support         = true
  enable_nat_gateway         = true
  single_nat_gateway         = true
  one_nat_gateway_per_az     = false
  manage_default_network_acl = false

  default_security_group_ingress = [
    {
      self = true
    }
  ]
  default_security_group_egress = [
    {
      self        = false
      cidr_blocks = "0.0.0.0/0"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
    }
  ]

# -- If you need to create unique tags for each subnet, uncomment the following lines for Karpenter Discovery
# -- https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/5.1.2#input_private_subnet_tags_per_az
  # private_subnet_tags_per_az = {
  #   "eu-central-1a" = {
  #     "karpenter.sh/discovery" = "<PLATFORM_NAME>"
  #   }
  # }

  tags = var.tags
}
