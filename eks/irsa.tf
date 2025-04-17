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
