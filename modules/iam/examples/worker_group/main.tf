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

module "worker_group_iam_role" {
  source = "../.."

  create_iam_kaniko       = false
  create_iam_worker_group = true

  region                   = var.region
  tenant_name              = local.tenant_name
  attach_worker_cni_policy = true
  attach_worker_efs_policy = true

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
