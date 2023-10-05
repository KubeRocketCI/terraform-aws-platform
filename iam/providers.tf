terraform {

  required_version = "= 1.5.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.17.0"
    }
    local  = ">= 2.4.0"
    random = ">= 3.5.1"
  }

  backend "s3" {
    bucket         = "terraform-states-<ACCOUNT_ID>"
    key            = "<REGION>/<CLUSTER_NAME>/iam/terraform.tfstate"
    region         = "<REGION>"
    acl            = "bucket-owner-full-control"
    dynamodb_table = "terraform_locks"
    encrypt        = true
  }

}

provider "aws" {
  region = var.region
}
