provider "aws" {
  region  = var.region
  profile = var.aws_profile
  assume_role {
    role_arn = var.role_arn
  }
}

locals {
  tenant_name = "test-tenant-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 4
  lower   = true
  upper   = false
  special = false
}

module "kaniko_iam_role" {
  source = "../.."

  create_iam_kaniko       = true
  create_iam_worker_group = false

  region                  = var.region
  tenant_name             = local.tenant_name
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
