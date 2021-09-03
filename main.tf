# Fill the gaps instead <...>

data "aws_eks_cluster" "cluster" {
  count = var.create_cluster ? 1 : 0
  name  = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  count = var.create_cluster ? 1 : 0
  name  = module.eks.cluster_id
}

data "aws_security_group" "default" {
  vpc_id = var.create_vpc ? module.vpc.vpc_id : var.vpc_id

  filter {
    name   = "group-name"
    values = ["default"]
  }
}

data "aws_route53_zone" "this" {
  name         = var.platform_domain_name
  private_zone = false
}

locals {
  default_security_group_id = data.aws_security_group.default.id
  lb_security_group_ids     = compact(concat(tolist([local.default_security_group_id, aws_security_group.cidr_blocks.id]), aws_security_group.prefix_list.*.id, var.public_security_group_ids))
  nat_public_cidrs          = var.create_vpc ? formatlist("%s/32", module.vpc.nat_public_ips) : var.nat_public_cidrs

  target_groups = [
    {
      "name"                 = "${var.platform_name}-infra-alb-http"
      "backend_port"         = "32080"
      "backend_protocol"     = "HTTP"
      "deregistration_delay" = "20"
      "health_check" = {
        healthy_threshold   = 5
        unhealthy_threshold = 2
        protocol            = "HTTP"
        matcher             = "404"
      }
    },
    {
      "name"                 = "${var.platform_name}-infra-alb-https"
      "backend_port"         = "32443"
      "backend_protocol"     = "HTTPS"
      "deregistration_delay" = "20"
      "health_check" = {
        healthy_threshold   = 5
        unhealthy_threshold = 2
        protocol            = "HTTPS"
        matcher             = "404"
      }
    },
  ]
}

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
  cluster_iam_role_name        = var.manage_cluster_iam_resources ? "ServiceRoleForEKS${var.platform_name}" : var.cluster_iam_role_name
  workers_role_name            = "ServiceRoleForEks${var.platform_name}WorkerNode"

  cluster_endpoint_private_access = true
  cluster_create_security_group   = false
  worker_create_security_group    = false

  cluster_security_group_id = local.default_security_group_id
  worker_security_group_id  = local.default_security_group_id

  kubeconfig_aws_authenticator_command       = var.kubeconfig_aws_authenticator_command
  kubeconfig_aws_authenticator_command_args  = var.kubeconfig_aws_authenticator_command == "aws" ? ["eks", "get-token", "--cluster-name", element(concat(data.aws_eks_cluster_auth.cluster[*].name, [""]), 0)] : []
  kubeconfig_aws_authenticator_env_variables = var.kubeconfig_aws_authenticator_env_variables

  # Add a separate map to the list for each new customer by copy-pasting spot or on-demand map example.
  # Note, the maps below here are just for example usage. Please, make sure to fill in the input variables
  # with values according to the needs of your project.
  worker_groups_launch_template = [
    {
      name                                     = "project-name-on-demand"
      override_instance_types                  = var.demand_instance_types
      asg_min_size                             = 0 # must be less or equal to desired_nodes_count
      asg_max_size                             = 0
      asg_desired_capacity                     = 0
      subnets                                  = var.create_vpc ? [module.vpc.private_subnets[0]] : [var.private_subnets_id[0]]
      on_demand_percentage_above_base_capacity = 100
      additional_userdata                      = var.add_userdata
      kubelet_extra_args                       = "--node-labels=node.kubernetes.io/lifecycle=normal"
      suspended_processes                      = ["AZRebalance", "ReplaceUnhealthy"]
      public_ip                                = false
      target_group_arns                        = module.alb.target_group_arns
      load_balancers                           = [module.elb.elb_name] # uncomment if you need Gerrit
      root_volume_size                         = 30
      enable_monitoring                        = false

      iam_instance_profile_name = var.worker_iam_instance_profile_name
      key_name                  = var.key_name
    },
    {
      name                    = "project-name-spot"
      override_instance_types = var.spot_instance_types
      spot_instance_pools     = 2
      subnets                 = var.create_vpc ? [module.vpc.private_subnets[0]] : [var.private_subnets_id[0]]
      asg_min_size            = 2 # must be less or equal to desired_nodes_count
      asg_max_size            = 2
      asg_desired_capacity    = 2
      additional_userdata     = var.add_userdata
      kubelet_extra_args      = "--node-labels=node.kubernetes.io/lifecycle=spot"
      suspended_processes     = []
      public_ip               = false
      target_group_arns       = module.alb.target_group_arns
      load_balancers          = [module.elb.elb_name] # uncomment if you need Gerrit
      root_volume_size        = 30
      enable_monitoring       = false

      iam_instance_profile_name = var.worker_iam_instance_profile_name
      key_name                  = var.key_name
    },
    /*
    {
      name                    = "<PROJECT_CODE>-spot"
      override_instance_types = var.spot_instance_types
      spot_instance_pools     = 0
      subnets                 = var.create_vpc ? [module.vpc.private_subnets[0]] : [var.private_subnets_id[0]]
      asg_min_size            = 0 # must be less or equal to desired_nodes_count
      asg_max_size            = 0
      asg_desired_capacity    = 0
      additional_userdata     = var.add_userdata
      kubelet_extra_args      = "--node-labels=node.kubernetes.io/lifecycle=spot"
      suspended_processes     = []
      public_ip               = false
      target_group_arns       = module.alb.target_group_arns
      load_balancers          = [module.elb.elb_name] # uncomment if you need Gerrit
      root_volume_size        = 30
      enable_monitoring       = false

      iam_instance_profile_name = "<IAM_PROFILE>"
      key_name                  = var.key_name

      tags = [
        {
          "key"                 = "user:tag"
          "propagate_at_launch" = "true"
          "value"               = "<PROJECT_CODE>" # specify project code to tag EC2 instances and volumes for customer resources granular billing
        }
      ]
    },
    {
      name                                     = "<PROJECT_CODE>-on-demand"
      override_instance_types                  = var.demand_instance_types
      asg_min_size                             = 0 # must be less or equal to desired_nodes_count
      asg_max_size                             = 0
      asg_desired_capacity                     = 0
      subnets                                  = var.create_vpc ? [module.vpc.private_subnets[0]] : [var.private_subnets_id[0]]
      on_demand_percentage_above_base_capacity = 100
      additional_userdata                      = var.add_userdata
      kubelet_extra_args                       = "--node-labels=node.kubernetes.io/lifecycle=normal"
      suspended_processes                      = ["AZRebalance", "ReplaceUnhealthy"]
      public_ip                                = false
      target_group_arns                        = module.alb.target_group_arns
      # load_balancers                           = [module.elb.elb_name] # uncomment if you need Gerrit
      root_volume_size  = 30
      enable_monitoring = false

      iam_instance_profile_name = "<IAM_PROFILE>"
      key_name                  = var.key_name

      tags = [
        {
          "key"                 = "user:tag"
          "propagate_at_launch" = "true"
          "value"               = "<PROJECT_CODE>" # specify project code to tag EC2 instances and volumes for customer resources granular billing
        }
      ]
    }
    */
  ]

  map_users = var.map_users
  map_roles = var.map_roles

  tags = var.tags
}
