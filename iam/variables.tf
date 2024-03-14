variable "create_iam_deployer" {
  description = "Whether to create IAM role for Kaniko pod"
  type        = bool
  default     = false
}

variable "create_iam_kaniko" {
  description = "Whether to create IAM role for Kaniko pod"
  type        = bool
  default     = false
}

variable "region" {
  description = "The AWS region to deploy the cluster into, e.g. eu-central-1"
  type        = string
}

variable "deployer_role_name" {
  description = "The AWS IAM role name for EKS cluster deployment"
  type        = string
  default     = "EKSDeployerRole"
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(any)
  default     = {}
}

variable "deployer_iam_permissions_boundary_policy_arn" {
  description = "ARN for permission boundary to attach to the Deployer IAM Role"
  type        = string
  default     = ""
}

variable "kaniko_iam_permissions_boundary_policy_arn" {
  description = "ARN for permission boundary to attach to the Kaniko IAM Role"
  type        = string
  default     = ""
}

variable "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  type        = string
  default     = "https://oidc.eks.eu-central-1.amazonaws.com/id/0123456789"
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  type        = string
  default     = "arn:aws:iam::0123456789:oidc-provider/oidc.eks.eu-central-1.amazonaws.com/id/0123456789"
}

variable "namespace" {
  description = "The namespace to deploy Kaniko"
  type        = string
  default     = "kaniko"
}

variable "kaniko_role_name" {
  description = "User defined Kaniko IAM role name to create"
  type        = string
  default     = ""
}
