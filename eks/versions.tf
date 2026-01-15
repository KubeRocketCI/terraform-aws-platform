terraform {

  required_version = "1.5.7"

  backend "s3" {
    bucket         = "terraform-states-<ACCOUNT_ID>"
    key            = "eks-test/eu-central-1/terraform/terraform.tfstate"
    region         = "eu-central-1"
    acl            = "bucket-owner-full-control"
    dynamodb_table = "terraform_locks"
    encrypt        = true
    role_arn       = "arn:aws:iam::<AWS_ACCOUNT_ID>:role/KRCIDeployerRole"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.28"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
  }
}
