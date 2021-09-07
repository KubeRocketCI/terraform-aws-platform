locals {
  oidc_issuer_url  = trimprefix(var.cluster_oidc_issuer_url, "https://")
  kaniko_role_name = "AWSIRSA${replace(title("${var.platform_name}${var.namespace}"), "-", "")}Kaniko"
}

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

resource "aws_iam_role" "kaniko" {
  count                 = var.create_iam_kaniko ? 1 : 0
  name                  = local.kaniko_role_name
  description           = "IAM role to be used by Kaniko pod"
  assume_role_policy    = data.aws_iam_policy_document.kaniko_policy[0].json
  force_detach_policies = true

  inline_policy {
    name = "AWSIRSAOpenLegacyEdpKaniko"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ecr:*",
            "cloudtrail:LookupEvents"
          ]
          Action   = "ecr:*"
          Effect   = "Allow"
          Resource = "arn:aws:ecr:${var.region}:${var.aws_account_id}:repository/${var.namespace}/*"
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
          Resource = "arn:aws:ecr:${var.region}:${var.aws_account_id}:repository/*"
        }
      ]
    })
  }
  tags = merge(var.tags, map("Name", local.kaniko_role_name))
}
