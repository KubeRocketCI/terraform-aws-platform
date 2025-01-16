##########################################################
#                   IRSA for CSI Driver                  #
##########################################################


module "aws_ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.47.1"

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

##########################################################
#                   IRSA for CNI Driver                  #
##########################################################

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.47.1"

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

##########################################################
#            IRSA for External Secret Operator           #
##########################################################

module "externalsecrets_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.47.1"

  role_name                     = "AWSIRSA_${replace(title(local.cluster_name), "-", "")}_ExternalSecretOperatorAccess"
  assume_role_condition_test    = "StringLike"
  role_permissions_boundary_arn = var.role_permissions_boundary_arn

  attach_external_secrets_policy = true
  policy_name_prefix             = "AWSIRSA_${replace(title(local.cluster_name), "-", "")}"
  external_secrets_ssm_parameter_arns = [
    "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/edp/*"
  ]

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["*"]
    }
  }
  tags = local.tags
}

##########################################################
#                    IRSA for Kaniko                     #
##########################################################

module "kaniko_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.47.1"

  create_role = var.create_kaniko_iam_role

  role_name                  = "AWSIRSA_${replace(title(local.cluster_name), "-", "")}_KanikoAccess"
  assume_role_condition_test = "StringLike"

  role_policy_arns = {
    policy = module.kaniko_iam_policy.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["*"]
    }
  }

  tags = local.tags
}

module "kaniko_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.47.1"

  create_policy = var.create_kaniko_iam_role

  name        = "AWSIRSA_${replace(title(local.cluster_name), "-", "")}_KanikoAccess"
  path        = "/"
  description = "IAM policy granting access to ECR and CloudTrail for Kaniko"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:*",
          "cloudtrail:LookupEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/*"
      },
      {
        Action   = "ecr:GetAuthorizationToken"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ecr:DescribeRepositories",
          "ecr:CreateRepository"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/*"
      }
    ]
  })

  tags = local.tags
}

##########################################################
#                  IRSA for Karpenter                    #
##########################################################

resource "aws_iam_role" "karpenter_node_provisioner" {
  name                  = "${var.karpenter_node_role_name}-${local.cluster_name}"
  description           = "Karpenter node provisioner role for EKS cluster"
  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy.json
  force_detach_policies = true
  permissions_boundary  = var.role_permissions_boundary_arn


  tags = merge(var.tags, tomap({ "Name" = var.karpenter_node_role_name }))
}

resource "aws_iam_role_policy_attachments_exclusive" "karpenter_node_provisioner" {
  role_name   = aws_iam_role.karpenter_node_provisioner.name
  policy_arns = [
    data.aws_iam_policy.AmazonEC2ContainerRegistryReadOnly.arn,
    data.aws_iam_policy.AmazonEKS_CNI_Policy.arn,
    data.aws_iam_policy.AmazonEKSWorkerNodePolicy.arn,
    data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn]
}

resource "aws_iam_role" "karpenter_controller_role" {
  name                  = "${var.karpenter_controller_role_name}-${local.cluster_name}"
  description           = "Karpenter Controller role for EKS cluster"
  assume_role_policy    = data.aws_iam_policy_document.instance_assume_role_policy.json
  force_detach_policies = true
  permissions_boundary  = var.role_permissions_boundary_arn


  tags = merge(var.tags, tomap({ "Name" = var.karpenter_node_role_name }))
}

resource "aws_iam_policy" "karpenter_controller" {
  name        = "${var.karpenter_controller_policy_name}-${local.cluster_name}"
  path        = "/"
  description = "Policy for Karpenter node provisioner role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetParameter",
          "ec2:DescribeImages",
          "ec2:RunInstances",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ec2:DeleteLaunchTemplate",
          "ec2:CreateTags",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:DescribeSpotPriceHistory",
          "pricing:GetProducts"
        ]
        Effect   = "Allow"
        Resource = "*"
        Sid = "Karpenter"
      },
      {
        Action = [
          "ec2:TerminateInstances"
        ]
        Condition = {
          StringLike = {
            "ec2:ResourceTag/karpenter.sh/nodepool": "*"
          }
        }
        Effect   = "Allow"
        Resource = "*"
        Sid = "ConditionalEC2Termination"
      },
      {
        Action = [
          "iam:PassRole"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.karpenter_node_role_name}-${local.cluster_name}"
        Sid = "PassNodeIAMRole"
      },
      {
        Action = [
          "eks:DescribeCluster"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:eks:eu-central-1:${data.aws_caller_identity.current.account_id}:cluster/${local.cluster_name}"
        Sid = "EKSClusterEndpointLookup"
      },
      {
        Action = [
          "iam:CreateInstanceProfile"
        ]
        Effect   = "Allow"
        Resource = "*"
        Sid = "AllowScopedInstanceProfileCreationActions"
        Condition = {
          StringEquals = {
              "aws:RequestTag/kubernetes.io/cluster/${local.cluster_name}": "owned",
              "aws:RequestTag/topology.kubernetes.io/region": "${var.region}",
          },
          StringLike = {
              "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass": "*"
          }
        }
      },
      {
        Action = [
          "iam:TagInstanceProfile"
        ]
        Effect   = "Allow"
        Resource = "*"
        Sid = "AllowScopedInstanceProfileTagActions"
        Condition = {
          StringEquals = {
              "aws:ResourceTag/kubernetes.io/cluster/${local.cluster_name}": "owned",
              "aws:ResourceTag/topology.kubernetes.io/region": "${var.region}",
              "aws:RequestTag/kubernetes.io/cluster/${local.cluster_name}": "owned",
              "aws:RequestTag/topology.kubernetes.io/region": "${var.region}",
          },
          StringLike = {
              "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass": "*",
              "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass": "*"
          }
        }
      },
      {
        Action = [
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:DeleteInstanceProfile"
        ]
        Effect   = "Allow"
        Resource = "*"
        Sid = "AllowScopedInstanceProfileActions"
        Condition = {
          StringEquals = {
              "aws:ResourceTag/kubernetes.io/cluster/${local.cluster_name}": "owned",
              "aws:ResourceTag/topology.kubernetes.io/region": "${var.region}",
          },
          StringLike = {
              "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass": "*"
          }
        }
      },
      {
        Action = [
          "iam:GetInstanceProfile"
        ]
        Effect   = "Allow"
        Resource = "*"
        Sid = "AllowInstanceProfileReadActions"
      },
    ]
  })
  tags = merge(var.tags, tomap({ "Name" = var.karpenter_node_role_name }))
}

resource "aws_iam_role_policy_attachments_exclusive" "karpenter_controller_role" {
  role_name   = aws_iam_role.karpenter_controller_role.name
  policy_arns = [aws_iam_policy.karpenter_controller.arn]
}
