terraform {
  required_version = "= 0.14.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 3.40.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}
