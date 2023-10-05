data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "kaniko_policy" {
  count = var.create_iam_kaniko ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_url}:sub"

      values = [
        "system:serviceaccount:${var.namespace}:edp-kaniko",
      ]
    }

  }
}
