module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.4"

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

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "4.0.1"

  domain_name = var.platform_domain_name
  zone_id     = data.aws_route53_zone.this.zone_id

  subject_alternative_names = [
    "*.${var.platform_name}.${var.platform_domain_name}",
    "${var.platform_name}.${var.platform_domain_name}",
  ]

  wait_for_validation = true
  validation_method   = "DNS"

  tags = merge(var.tags, tomap({ "Name" = var.platform_name }))
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "7.0.0"

  name            = "${var.platform_name}-ingress-alb"
  security_groups = compact(concat(tolist([local.default_security_group_id]), var.infrastructure_public_security_group_ids))
  enable_http2    = false
  subnets         = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "forward"
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

  target_groups = local.target_groups
  idle_timeout  = 300

  tags = var.tags
}

module "elb" {
  source  = "terraform-aws-modules/elb/aws"
  version = "3.0.1"

  create_elb = var.create_elb

  name = format("%s-infra-external", var.platform_name)

  subnets         = module.vpc.public_subnets
  security_groups = compact(concat(tolist([local.default_security_group_id]), var.infrastructure_public_security_group_ids))
  tags            = merge(var.tags, tomap({ "Name" = "${var.platform_name}-infra-external" }))
  internal        = false
  idle_timeout    = 300

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
      # gerrit requires 80 port to be openned, since it's used by gerrit-jenkins plugin
      instance_port     = "32080"
      instance_protocol = "http"
      lb_port           = "80"
      lb_protocol       = "http"
    },
    {
      instance_port     = "30022"
      instance_protocol = "tcp"
      lb_port           = "30022" //Gerrit port
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
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.24.0"

  cluster_name    = var.platform_name
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.private_subnets
  cluster_version = var.cluster_version
  enable_irsa     = var.enable_irsa

  manage_cluster_iam_resources = false
  cluster_iam_role_name        = var.cluster_iam_role_name
  manage_worker_iam_resources  = false

  cluster_create_security_group = false
  cluster_security_group_id     = local.default_security_group_id
  worker_create_security_group  = false
  worker_security_group_id      = local.default_security_group_id

  cluster_endpoint_private_access = true
  write_kubeconfig                = false

  worker_groups_launch_template = [
    {
      name                                     = "${var.platform_name}-on-demand"
      override_instance_types                  = var.demand_instance_types
      subnets                                  = [module.vpc.private_subnets[0]]
      asg_min_size                             = var.demand_min_nodes_count
      asg_max_size                             = var.demand_max_nodes_count
      asg_desired_capacity                     = var.demand_desired_nodes_count
      on_demand_percentage_above_base_capacity = 100
      additional_userdata                      = var.add_userdata
      kubelet_extra_args                       = "--node-labels=node.kubernetes.io/lifecycle=normal"
      suspended_processes                      = ["AZRebalance", "ReplaceUnhealthy"]
      public_ip                                = false
      target_group_arns                        = module.alb.target_group_arns
      load_balancers                           = [module.elb.elb_id]
      root_volume_size                         = 50
      enable_monitoring                        = false

      iam_instance_profile_name = var.worker_iam_instance_profile_name
      key_name                  = var.key_name
    },
    {
      name                    = "${var.platform_name}-spot"
      override_instance_types = var.spot_instance_types
      subnets                 = [module.vpc.private_subnets[0]]
      spot_instance_pools     = 3
      asg_min_size            = var.spot_min_nodes_count
      asg_max_size            = var.spot_max_nodes_count
      asg_desired_capacity    = var.spot_desired_nodes_count
      additional_userdata     = var.add_userdata
      kubelet_extra_args      = "--node-labels=node.kubernetes.io/lifecycle=spot"
      suspended_processes     = []
      public_ip               = false
      target_group_arns       = module.alb.target_group_arns
      load_balancers          = [module.elb.elb_id]
      root_volume_size        = 50
      enable_monitoring       = false

      iam_instance_profile_name = var.worker_iam_instance_profile_name
      key_name                  = var.key_name
    },
  ]

  map_users = var.map_users
  map_roles = var.map_roles

  tags = var.tags
}

module "records" {
  source    = "terraform-aws-modules/route53/aws//modules/records"
  version   = "2.9.0"
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