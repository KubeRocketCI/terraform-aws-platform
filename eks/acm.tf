module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.2.0"

  domain_name = var.platform_domain_name
  zone_id     = data.aws_route53_zone.this.zone_id

  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.platform_domain_name}",
  ]

  tags = merge(local.tags, tomap({ "Name" = var.platform_name }))
}
