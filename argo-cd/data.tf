# This policy is used by ArgoCD "Master" which is deployed in Shared account
# and manages all cluster deployments. The policy allows to assume roles in remote accounts
# These remote roles are EKS cluster admins
data "aws_iam_policy_document" "argocd_master" {
  count = local.argocd_master_is_enabled ? 1 : 0

  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    resources = var.argocd_master_role_name_list
  }
}
