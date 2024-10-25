#---------------------------------------------#
# ArgoCD Master Deployment
#---------------------------------------------#
resource "aws_iam_policy" "argocd_irsa_policy" {
  count = local.argocd_master_is_enabled ? 1 : 0

  name   = "AWSIRSA_${replace(title(local.cluster_name), "-", "")}_ArgoCDMaster"
  policy = data.aws_iam_policy_document.argocd_master[0].json

  tags = local.tags
}

# Argocd Role is assigned to argocd server and argocd controller and is used to assume role in remote accounts
# to provision resources in remote eks clusters
module "argocd_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.47.1"

  create_role = local.argocd_master_is_enabled

  role_name                     = "AWSIRSA_${replace(title(local.cluster_name), "-", "")}_ArgoCDMaster"
  assume_role_condition_test    = "StringLike"
  role_permissions_boundary_arn = var.role_permissions_boundary_arn
  role_policy_arns = {
    argocd_policy = try(aws_iam_policy.argocd_irsa_policy[0].arn, null)
  }

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["argocd:*"]
    }
  }

  tags = local.tags
}

#---------------------------------------------#
# ArgoCD Agent Deployment
#---------------------------------------------#
resource "aws_iam_role" "argocd_agent_role" {
  count = var.argocd_agent_enabled ? 1 : 0

  name                 = var.argocd_agent_role_name
  permissions_boundary = var.role_permissions_boundary_arn
  assume_role_policy   = data.aws_iam_policy_document.assume_role_policy[0].json
  tags                 = var.tags
}

data "aws_iam_policy_document" "assume_role_policy" {
  count = var.argocd_agent_enabled ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [var.argocd_agent_argocd_master_role_arn]
    }
  }
}
