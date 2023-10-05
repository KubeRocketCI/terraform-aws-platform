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

variable "iam_permissions_boundary_policy_arn" {
  description = "ARN for permission boundary to attach to IAM policies"
  type        = string
  default     = ""
}

variable "create_iam_deployer" {
  description = "Whether to create IAM role for deployer pod"
  type        = bool
  default     = false
}
