module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.0.0"

  create_vpc = var.create_vpc

  name = var.platform_name

  cidr            = var.platform_cidr
  azs             = var.subnet_azs
  private_subnets = var.private_cidrs
  public_subnets  = var.public_cidrs

  enable_dns_hostnames   = true
  enable_dns_support     = true
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  tags = var.tags
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "2.0.0"

  create = var.create_cluster

  zone_name = var.platform_domain_name

  records = [
    {
      name    = "*.${var.platform_name}"
      type    = "CNAME"
      ttl     = 300
      records = [module.alb.lb_dns_name]
    }
  ]
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "3.0.0"

  create_certificate = var.create_cluster

  domain_name = var.platform_domain_name
  zone_id     = data.aws_route53_zone.this.zone_id

  subject_alternative_names = [
    "${var.platform_name}.${var.platform_domain_name}",
    "*.${var.platform_name}.${var.platform_domain_name}",
  ]

  wait_for_validation = var.wait_for_validation
  validation_method   = "DNS"

  tags = merge(var.tags, map("Name", var.platform_name))
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "6.0.0"

  create_lb = var.create_cluster

  name = "${var.platform_name}-alb"

  load_balancer_type = "application"

  vpc_id          = var.create_vpc ? module.vpc.vpc_id : var.vpc_id
  subnets         = var.create_vpc ? module.vpc.public_subnets : var.public_subnets_id
  security_groups = local.lb_security_group_ids
  idle_timeout    = 500
  enable_http2    = false

  target_groups = local.target_groups

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 1
      ssl_policy         = var.ssl_policy
    }
  ]

  tags = var.tags
}

# ELB is only used for Gerrit
module "elb" {
  source  = "terraform-aws-modules/elb/aws"
  version = "3.0.0"

  create_elb = var.create_elb && var.create_cluster

  name = "${var.platform_name}-elb"

  subnets         = var.create_vpc ? module.vpc.public_subnets : var.public_subnets_id
  security_groups = local.lb_security_group_ids
  idle_timeout    = 300
  internal        = false

  listener = [
    {
      # ELB 443 port should point to nginx-ingress NodePort (32080) for HTTP traffic
      instance_port      = "32080"
      instance_protocol  = "http"
      lb_port            = "443"
      lb_protocol        = "https"
      ssl_certificate_id = module.acm.acm_certificate_arn
    },
    {
      # ELB 80 port should point to nginx-ingress NodePort (32080) for HTTP traffic
      # Gerrit requires 80 port to be openned, since it's used by gerrit-jenkins plugin
      instance_port     = "32080"
      instance_protocol = "http"
      lb_port           = "80"
      lb_protocol       = "http"
    },
    {
      instance_port     = "30022"
      instance_protocol = "tcp"
      lb_port           = "30022" # Gerrit port
      lb_protocol       = "tcp"
    }
  ]

  health_check = {
    target              = "TCP:22"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  tags = var.tags
}

module "eks" {
  source = "github.com/epmd-edp/terraform-aws-eks.git?ref=edp-v17.0.2"

  create_eks = var.create_cluster

  cluster_name = var.platform_name

  vpc_id  = var.create_vpc ? module.vpc.vpc_id : var.vpc_id
  subnets = var.create_vpc ? module.vpc.private_subnets : var.private_subnets_id

  cluster_version = var.cluster_version
  enable_irsa     = var.enable_irsa

  manage_cluster_iam_resources = var.manage_cluster_iam_resources
  manage_worker_iam_resources  = var.manage_worker_iam_resources
  cluster_iam_role_name        = var.manage_cluster_iam_resources ? local.cluster_iam_role_name_to_create : var.cluster_iam_role_name
  workers_role_name            = var.manage_worker_iam_resources ? local.worker_iam_role_name_to_create : ""

  cluster_endpoint_private_access = true
  cluster_create_security_group   = false
  worker_create_security_group    = false
  cluster_security_group_id       = local.default_security_group_id
  worker_security_group_id        = local.default_security_group_id

  kubeconfig_aws_authenticator_command       = var.kubeconfig_aws_authenticator_command
  kubeconfig_aws_authenticator_command_args  = var.kubeconfig_aws_authenticator_command == "aws" ? ["eks", "get-token", "--cluster-name", element(concat(data.aws_eks_cluster_auth.cluster[*].name, [""]), 0)] : []
  kubeconfig_aws_authenticator_env_variables = var.kubeconfig_aws_authenticator_env_variables

  worker_groups_launch_template = local.worker_groups_launch_template_merged

  map_users = var.map_users
  map_roles = var.map_roles

  tags = var.tags
}
