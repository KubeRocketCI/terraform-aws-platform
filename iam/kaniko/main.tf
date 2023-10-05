resource "random_string" "suffix" {
  count = var.create_iam_kaniko ? 1 : 0

  length  = 4
  lower   = true
  upper   = false
  special = false
}

resource "aws_iam_role" "kaniko" {
  count = var.create_iam_kaniko ? 1 : 0

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
          Resource = "arn:aws:ecr:${var.region}:${local.aws_account_id}:repository/${var.namespace}/*"
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
          Resource = "arn:aws:ecr:${var.region}:${local.aws_account_id}:repository/*"
        }
      ]
    })
  }
  tags = merge(var.tags, tomap({ "Name" = local.kaniko_role_name }))
}
