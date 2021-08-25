variable "region" {
  description = "The AWS region to deploy the cluster into, e.g. eu-central-1"
  type        = string
}

variable "aws_profile" {
  description = "The AWS profile name to use for running terraform, look for the name in the ~/.aws/config local file"
  type        = string
}

variable "role_arn" {
  description = "The AWS IAM role arn to assume for running terraform (e.g. arn:aws:iam::012345678910:role/EKSDeployerRole)"
  type        = string
  default     = ""
}

variable "aws_root_account_id" {
  description = "The AWS root account id"
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
