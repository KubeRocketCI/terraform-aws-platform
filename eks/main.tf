resource "aws_autoscaling_attachment" "self_managed_asg_tg" {
  for_each = {
    spot      = module.eks.self_managed_node_groups_autoscaling_group_names[0]
    on_demand = module.eks.self_managed_node_groups_autoscaling_group_names[1]
  }

  autoscaling_group_name = each.value
  lb_target_group_arn    = module.alb.target_groups["http-instance"].arn
}

module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "2.1.0"

  key_name              = format("%s-%s", local.cluster_name, "key-pair")
  private_key_algorithm = "ED25519"
  create_private_key    = true

  tags = local.tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.1.0"

  access_entries = {
    clusteradmin = {
      principal_arn = join("", data.aws_iam_roles.admin_role.arns)
      type          = "STANDARD"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
    atlantis_clusteradmin = {
      principal_arn = module.atlantis_iam_role.arn
      type          = "STANDARD"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  enable_cluster_creator_admin_permissions = true
  name                                     = local.cluster_name
  kubernetes_version                       = var.cluster_version
  endpoint_public_access                   = true

  create_iam_role               = true
  iam_role_use_name_prefix      = false
  iam_role_permissions_boundary = var.role_permissions_boundary_arn

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets_id

  create_cloudwatch_log_group        = false
  enabled_log_types                  = []
  create_node_security_group         = false
  create_primary_security_group_tags = false

  create_security_group = false
  security_group_id     = local.cluster_security_group_id

  encryption_config = {}

  self_managed_node_groups = {
    worker_group_spot = {
      ami_type                   = "AL2023_x86_64_STANDARD"
      instance_type              = "m7i.xlarge"
      name                       = format("%s-%s", local.cluster_name, "spot")
      subnet_ids                 = [var.private_subnets_id[1]]
      key_name                   = module.key_pair.key_pair_name
      enable_monitoring          = false
      use_mixed_instances_policy = true
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

      min_size     = var.spot_min_nodes_count
      max_size     = var.spot_max_nodes_count
      desired_size = var.spot_desired_nodes_count

      iam_role_use_name_prefix      = false
      iam_role_permissions_boundary = var.role_permissions_boundary_arn

      cloudinit_pre_nodeadm = [{
        content      = var.add_userdata
        content_type = "text/x-shellscript; charset=\"us-ascii\""
        },
        {
          content      = <<-EOT
          ---
          apiVersion: node.eks.aws/v1alpha1
          kind: NodeConfig
          spec:
            kubelet:
              flags:
                - --node-labels=node.kubernetes.io/lifecycle=spot
        EOT
          content_type = "application/node.eks.aws"
      }]

      create_iam_instance_profile = true

      mixed_instances_policy = {
        instances_distribution = {
          spot_instance_pools = 2
        }
        launch_template = {
          override = var.spot_instance_types
        }
      }
    },
    worker_group_on_demand = {
      ami_type                   = "AL2023_x86_64_STANDARD"
      instance_type              = "m7i.xlarge"
      name                       = format("%s-%s", local.cluster_name, "on-demand")
      subnet_ids                 = var.private_subnets_id
      key_name                   = module.key_pair.key_pair_name
      enable_monitoring          = false
      use_mixed_instances_policy = true
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

      min_size     = var.demand_min_nodes_count
      max_size     = var.demand_max_nodes_count
      desired_size = var.demand_desired_nodes_count

      iam_role_use_name_prefix      = false
      iam_role_permissions_boundary = var.role_permissions_boundary_arn

      cloudinit_pre_nodeadm = [{
        content      = var.add_userdata
        content_type = "text/x-shellscript; charset=\"us-ascii\""
        },
        {
          content      = <<-EOT
          ---
          apiVersion: node.eks.aws/v1alpha1
          kind: NodeConfig
          spec:
            kubelet:
              flags:
                - --node-labels=node.kubernetes.io/lifecycle=normal
        EOT
          content_type = "application/node.eks.aws"
      }]

      create_iam_instance_profile = true

      mixed_instances_policy = {
        launch_template = {
          override = var.spot_instance_types
        }
      }
    },
  }

  # OIDC Identity provider
  identity_providers = var.cluster_identity_providers

  # Addons
  # Verify the addon versions with: aws eks describe-addon-versions --addon-name addon-name --kubernetes-version 1.32
  addons = {
    aws-ebs-csi-driver = {
      addon_version            = "v1.47.0-eksbuild.1"
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = module.aws_ebs_csi_driver_irsa.arn
    }
    snapshot-controller = {
      addon_version            = "v8.3.0-eksbuild.1"
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = module.aws_ebs_csi_driver_irsa.arn
    }
    coredns = {
      addon_version     = "v1.11.4-eksbuild.14"
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      addon_version     = "v1.32.6-eksbuild.2"
      resolve_conflicts = "OVERWRITE"
    }
    vpc-cni = {
      addon_version            = "v1.20.0-eksbuild.1"
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = module.vpc_cni_irsa.arn
    }
  }

  tags = local.tags
}

