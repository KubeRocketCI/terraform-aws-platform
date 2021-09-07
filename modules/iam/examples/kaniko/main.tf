provider "aws" {
  region  = var.region
  profile = var.aws_profile
  assume_role {
    role_arn = var.role_arn
  }
}

locals {
  platform_name = "test-iam-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 4
  special = false
}

module "kaniko_iam_role" {
  source            = "../.."
  create_iam_kaniko = true

  region                  = var.region
  aws_account_id          = var.aws_account_id
  platform_name           = local.platform_name
  cluster_oidc_issuer_url = var.cluster_oidc_issuer_url
  oidc_provider_arn       = var.oidc_provider_arn
  namespace               = var.namespace

  tags = {
    "SysName"      = "EKS"
    "SysOwner"     = "owner@example.com"
    "Environment"  = "EKS-TEST-CLUSTER"
    "CostCenter"   = "2020"
    "BusinessUnit" = "BU"
    "Department"   = "DEPARTMENT"
    "user:tag"     = "test-eks"
  }
}
