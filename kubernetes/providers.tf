terraform {
  required_version = "= 0.14.10"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "= 2.2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "= 2.3.2"
    }
  }
}
