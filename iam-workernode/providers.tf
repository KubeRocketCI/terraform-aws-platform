terraform {
  required_version = "1.2.9"

  # Fill the gaps instead <...>
  backend "s3" {
    bucket         = "terraform-states-<AWS_ACCOUNT_ID>"
    key            = "<PROJECT_NAME>/<REGION>/terraform/terraform.tfstate"
    region         = "<REGION>"
    acl            = "bucket-owner-full-control"
    dynamodb_table = "terraform_locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.30.0"
    }
  }
}

provider "aws" {
  region = var.region
  assume_role {
    role_arn = var.role_arn
  }
}
