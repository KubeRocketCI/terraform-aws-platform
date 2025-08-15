##########################################################
#                   IRSA for Atlantis                    #
##########################################################

module "atlantis_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "6.1.0"

  create = var.create_atlantis_iam_role

  name                 = var.atlantis_role_name
  trust_condition_test = "StringLike"
  permissions_boundary = var.role_permissions_boundary_arn
  use_name_prefix      = false

  policies = {
    policy = module.atlantis_iam_policy.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["atlantis:atlantis"]
    }
  }

  tags = local.tags
}

module "atlantis_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "6.1.0"

  create = var.create_atlantis_iam_role

  name        = "AWSIRSA_${replace(title(local.cluster_name), "-", "")}_AtlantisAccess"
  path        = "/"
  description = "IAM policy allowing Atlantis to assume KRCIDeployerRole"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = var.role_arn
      }
    ]
  })

  tags = local.tags
}
