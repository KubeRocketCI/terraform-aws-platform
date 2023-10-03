module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "4.3.2"

  domain_name = var.platform_domain_name
  zone_id     = data.aws_route53_zone.this.zone_id

  subject_alternative_names = [
    "${var.platform_name}.${var.platform_domain_name}",
    "*.${var.platform_name}.${var.platform_domain_name}",
  ]

  tags = merge(local.tags, tomap({ "Name" = var.platform_name }))
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.7.0"

  name = "${var.platform_name}-ingress-alb"

  vpc_id                = var.vpc_id
  subnets               = var.public_subnets_id
  create_security_group = false
  security_groups       = var.infra_public_security_group_ids
  enable_http2          = false

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  https_listeners = [
    {
      certificate_arn    = module.acm.acm_certificate_arn
      port               = 443
      target_group_index = 1
      ssl_policy         = var.ssl_policy
    }
  ]

  target_groups = [
    {
      "name"                 = "${var.platform_name}-infra-alb-http"
      "backend_port"         = "32080"
      "backend_protocol"     = "HTTP"
      "deregistration_delay" = "20"
      "health_check_matcher" = "404"
    },
    {
      "name"                 = "${var.platform_name}-infra-alb-https"
      "backend_port"         = "32443"
      "backend_protocol"     = "HTTPS"
      "deregistration_delay" = "20"
      "health_check_matcher" = "404"
    },
  ]
  idle_timeout = 500
  access_logs = {
    bucket = "prod-s3-elb-logs-eu-central-1"
  }

  tags = local.tags
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "2.10.2"

  zone_name = var.platform_domain_name
  records = [
    {
      name = "*.${var.platform_name}"
      type = "A"
      alias = {
        name    = module.alb.lb_dns_name
        zone_id = module.alb.lb_zone_id
      }
    }
  ]
}

module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "2.0.2"

  key_name              = format("%s-%s", local.cluster_name, "key-pair")
  private_key_algorithm = "ED25519"
  create_private_key    = true

  tags = local.tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.16.0"

  cluster_name                   = local.cluster_name
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true

  create_iam_role               = true
  iam_role_use_name_prefix      = false
  iam_role_permissions_boundary = var.role_permissions_boundary_arn

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets_id

  create_cloudwatch_log_group                = false
  cluster_enabled_log_types                  = []
  create_node_security_group                 = false
  create_cluster_primary_security_group_tags = false

  create_cluster_security_group = false
  cluster_security_group_id     = local.cluster_security_group_id

  cluster_encryption_config = {}

  # Self Managed Node Group(s)
  self_managed_node_group_defaults = {
    instance_type                 = "r5.large"
    subnet_ids                    = [var.private_subnets_id[1]] # deploy in eu-central-1b
    post_bootstrap_user_data      = var.add_userdata
    target_group_arns             = module.alb.target_group_arns
    key_name                      = module.key_pair.key_pair_name
    enable_monitoring             = false
    use_mixed_instances_policy    = true
    iam_role_use_name_prefix      = false
    iam_role_permissions_boundary = var.role_permissions_boundary_arn
    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size           = 30
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 150
          encrypted             = false
          delete_on_termination = true
        }
      }
    }

    # IAM role
    create_iam_instance_profile = true
  }

  self_managed_node_groups = {
    worker_group_spot = {
      name = format("%s-%s", local.cluster_name, "spot")

      min_size     = var.spot_min_nodes_count
      max_size     = var.spot_max_nodes_count
      desired_size = var.spot_desired_nodes_count

      iam_role_use_name_prefix      = false
      iam_role_permissions_boundary = var.role_permissions_boundary_arn

      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=spot'"

      mixed_instances_policy = {
        instances_distribution = {
          spot_instance_pools = 2
        }
        override = var.spot_instance_types
      }

      # Schedulers
      create_schedule = true
      schedules = {
        "Start" = {
          min_size     = var.spot_min_nodes_count
          max_size     = var.spot_max_nodes_count
          desired_size = var.spot_desired_nodes_count
          recurrence   = "00 6 * * MON-FRI"
          time_zone    = "Etc/UTC"
        },
        "Stop" = {
          min_size     = 0
          max_size     = 0
          desired_size = 0
          recurrence   = "00 18 * * MON-FRI"
          time_zone    = "Etc/UTC"
        },
      }
    },
    worker_group_on_demand = {
      name = format("%s-%s", local.cluster_name, "on-demand")

      min_size     = var.demand_min_nodes_count
      max_size     = var.demand_max_nodes_count
      desired_size = var.demand_desired_nodes_count

      iam_role_use_name_prefix      = false
      iam_role_permissions_boundary = var.role_permissions_boundary_arn

      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=normal'"

      mixed_instances_policy = {
        override = var.demand_instance_types
      }

      # Schedulers
      create_schedule = true
      schedules = {
        "Start" = {
          min_size     = var.demand_min_nodes_count
          max_size     = var.demand_max_nodes_count
          desired_size = var.demand_desired_nodes_count
          recurrence   = "00 6 * * MON-FRI"
          time_zone    = "Etc/UTC"
        },
        "Stop" = {
          min_size     = 0
          max_size     = 0
          desired_size = 0
          recurrence   = "00 18 * * MON-FRI"
          time_zone    = "Etc/UTC"
        },
      }
    },
  }

  # aws-auth configmap
  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true

  aws_auth_users = var.aws_auth_users

  # OIDC Identity provider
  cluster_identity_providers = var.cluster_identity_providers

  # Addons
  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.aws_ebs_csi_driver_irsa.iam_role_arn
    }
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent              = true
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    }
  }

  tags = local.tags
}

module "kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.32.1"

  eks_cluster_id                = module.eks.cluster_name
  eks_cluster_endpoint          = module.eks.cluster_endpoint
  eks_oidc_provider             = module.eks.oidc_provider
  eks_cluster_version           = module.eks.cluster_version
  irsa_iam_permissions_boundary = var.role_permissions_boundary_arn

  # ArgoCD addon docs: https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/docs/add-ons/argocd.md
  # Example: https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/examples/argocd/main.tf

  # Enabled ArgoCD deploymend
  enable_argocd         = var.enable_argocd
  argocd_manage_add_ons = var.argocd_manage_add_ons
  argocd_helm_config = {
    repository = "https://argoproj.github.io/argo-helm"
    values     = [file("${path.module}/values/argocd-values.yaml")]
    version    = "5.33.2"
  }
  # Specify repository for ArgoCD
  argocd_applications = {
    eks-addons = {
      path                = var.addons_path
      repo_url            = var.repo_url
      add_on_application  = true
      ssh_key_secret_name = var.eks_addons_repo_ssh_key_secret_name
      insecure            = false
    }
  }
  tags = local.tags
}


module "aws_ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.28.0"

  role_name                     = "AWSIRSA_${replace(title(local.cluster_name), "-", "")}_EBS_CSI_Driver"
  role_permissions_boundary_arn = var.role_permissions_boundary_arn
  role_policy_arns = {
    AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.tags
}

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.28.0"

  role_name                     = "AWSIRSA_${replace(title(local.cluster_name), "-", "")}_VPC_CNI"
  role_permissions_boundary_arn = var.role_permissions_boundary_arn

  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
  tags = local.tags
}
