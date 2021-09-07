variable "create_iam_kaniko" {
  description = "Controls if IAM role for Kaniko pod should be created"
  type        = bool
  default     = false
}

variable "region" {
  description = "The AWS region to deploy the cluster into, e.g. eu-central-1"
  type        = string
}

variable "aws_account_id" {
  description = "The AWS account id"
  type        = string
}

variable "platform_name" {
  description = "The name of the cluster that is used for tagging resources. Match the [a-z0-9_-]"
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  type        = string
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  type        = string
}

variable "namespace" {
  description = "The ARN of the OIDC Provider"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(any)
  default     = {}
}
