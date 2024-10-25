variable "platform_name" {
  description = "The name of the cluster that is used for tagging resources. Match the [a-z0-9_-]"
  type        = string
}

variable "platform_cidr" {
  description = "CIRD of your future or existing VPC"
  type        = string
}

variable "subnet_azs" {
  description = "Available zones of your future or existing subnets"
  type        = list(any)
  default     = []
}

variable "private_cidrs" {
  description = "CIRD of your future or existing VPC"
  type        = list(any)
  default     = []
}

variable "public_cidrs" {
  description = "CIRD of your future or existing VPC"
  type        = list(any)
  default     = []
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(any)
  default     = {}
}

variable "region" {
  description = "The AWS region to deploy the cluster into (e.g. eu-central-1)"
  type        = string
  default     = ""
}

variable "role_arn" {
  description = "The AWS IAM role arn to assume for running terraform (e.g. arn:aws:iam::012345678910:role/KRCIDeployerRole)"
  type        = string
  default     = ""
}
