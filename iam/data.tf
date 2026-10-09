data "aws_caller_identity" "current" {}

locals {
  deployer_role_trusted_arns = concat(
    var.deployer_role_trust_account ? ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"] : [],
    var.deployer_role_trusted_principal_arns,
  )
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    dynamic "principals" {
      for_each = var.deployer_role_trust_ec2 ? ["ec2.amazonaws.com"] : []

      content {
        type        = "Service"
        identifiers = [principals.value]
      }
    }

    dynamic "principals" {
      for_each = length(local.deployer_role_trusted_arns) > 0 ? [local.deployer_role_trusted_arns] : []

      content {
        type        = "AWS"
        identifiers = principals.value
      }
    }
  }

  lifecycle {
    precondition {
      condition     = var.deployer_role_trust_ec2 || length(local.deployer_role_trusted_arns) > 0
      error_message = "The deployer role has nobody to trust. Set deployer_role_trust_account or deployer_role_trust_ec2 to true, or list principals in deployer_role_trusted_principal_arns."
    }
  }
}

check "deployer_role_trust" {
  assert {
    condition     = alltrue([for arn in local.deployer_role_trusted_arns : !endswith(arn, ":root")])
    error_message = "The deployer role trusts a whole AWS account: every identity of it whose own IAM policy allows sts:AssumeRole on the role. Set deployer_role_trust_account to false and list the roles and users that run Terraform in deployer_role_trusted_principal_arns."
  }

  assert {
    condition     = !var.deployer_role_trust_ec2
    error_message = "deployer_role_trust_ec2 lets EC2 instances assume the deployer role. Set it to false unless Terraform runs on an instance that carries the role."
  }
}
