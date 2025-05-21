terraform {

  required_version = "= 1.5.4"

  backend "s3" {
    bucket         = "terraform-states-<ACCOUNT_ID>"
    key            = "eks-test/eu-central-1/argo-cd/terraform.tfstate"
    region         = "eu-central-1"
    acl            = "bucket-owner-full-control"
    dynamodb_table = "terraform_locks"
    encrypt        = true
    role_arn       = "arn:aws:iam::<AWS_ACCOUNT_ID>:role/KRCIDeployerRole"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.8.0"
    }
  }
}

provider "aws" {
  region = var.region
  assume_role {
    role_arn = var.role_arn
  }
}
