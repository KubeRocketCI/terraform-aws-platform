variable "region" {
  description = "The AWS region to deploy the cluster into, e.g. eu-central-1"
  type        = string
  default     = "eu-central-1"
}

variable "aws_profile" {
  description = "(If required) The AWS profile name to use for running terraform, look for the name in the ~/.aws/config local file"
  type        = string
}

variable "role_arn" {
  description = "(If required) The AWS IAM role arn to assume for running terraform (e.g. arn:aws:iam::012345678910:role/EKSDeployerRole)"
  type        = string
}
