terraform {
  required_version = "= 1.5.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.17.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-states-<ACCOUNT_ID>"
    key            = "<CLUSTER_NAME>/<REGION>/vpc/terraform.tfstate"
    region         = "<REGION>"
    acl            = "bucket-owner-full-control"
    dynamodb_table = "terraform_locks"
    encrypt        = true
  }

}

provider "aws" {
  region = var.region
  assume_role {
    role_arn = var.role_arn
  }
}
