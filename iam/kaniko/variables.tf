variable "region" {
  description = "The AWS region to deploy the cluster into, e.g. eu-central-1"
  type        = string
  default     = "eu-central-1"
}

variable "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  type        = string
  default     = "https://oidc.eks.eu-central-1.amazonaws.com/id/0123456789"
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  type        = string
  default     = "arn:aws:iam::012345678910:oidc-provider/oidc.eks.eu-central-1.amazonaws.com/id/0123456789"
}

variable "namespace" {
  description = "The namespace to deploy Kaniko"
  type        = string
  default     = "kaniko"
}

variable "kaniko_role_name" {
  description = "The namespace to deploy Kaniko"
  type        = string
}

variable "create_iam_kaniko" {
  description = "Whether to create IAM role for Kaniko pod"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(any)
  default     = {}
}
