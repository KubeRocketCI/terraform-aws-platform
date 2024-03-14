data "aws_caller_identity" "current" {}

data "aws_route53_zone" "this" {
  name         = var.platform_domain_name
  private_zone = false
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = var.vpc_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = local.cluster_name
}
