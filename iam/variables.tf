variable "region" {
  description = "The AWS region to deploy the cluster into, e.g. eu-central-1"
  type        = string
}

variable "deployer_role_name" {
  description = "The AWS IAM role name for EKS cluster deployment"
  type        = string
  default     = "KRCIDeployerRole"
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(any)
  default     = {}
}

variable "iam_permissions_boundary_policy_arn" {
  description = "ARN for permission boundary to attach to IAM policies"
  type        = string
  default     = ""
}
