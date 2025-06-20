variable "region" {
  description = "The AWS region to deploy the cluster into (e.g. eu-central-1)"
  type        = string
  default     = ""
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.30"
}

variable "platform_name" {
  description = "The name of the cluster that is used for tagging resources"
  type        = string
  default     = ""
}

variable "role_arn" {
  description = "The AWS IAM role arn to assume for running terraform (e.g. arn:aws:iam::012345678910:role/KRCIDeployerRole)"
  type        = string
  default     = ""
}

variable "create_kaniko_iam_role" {
  description = "Enable or disable the creation of IAM role and policy for Kaniko"
  type        = bool
  default     = false
}

variable "platform_domain_name" {
  description = "The name of existing DNS zone for platform"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster security group will be provisioned"
  type        = string
  default     = ""
}

variable "private_subnets_id" {
  description = "A list of subnet IDs where the nodes/node groups will be provisioned"
  type        = list(any)
  default     = []
}

variable "public_subnets_id" {
  description = "A list of subnets to place the LB and other external resources"
  type        = list(any)
  default     = []
}

variable "ssl_policy" {
  description = "Predefined SSL security policy for ALB https listeners"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-3-2021-06"
}

variable "infra_public_security_group_ids" {
  description = "Security group IDs should be attached to external ALB"
  type        = list(any)
  default     = []
}

variable "add_userdata" {
  description = "User data that is appended to the user data script after of the EKS bootstrap script"
  type        = string
  default     = ""
}

variable "role_permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for IAM role"
  type        = string
  default     = ""
}

# Variables for spot pool
variable "spot_instance_types" {
  description = "AWS instance type to build nodes for spot pool"
  type        = list(any)
  default     = [{ instance_type = "r5.xlarge" }, { instance_type = "r5.2xlarge" }]
}

variable "spot_max_nodes_count" {
  description = "The maximum size of the spot autoscaling group"
  type        = number
  default     = 1
}

variable "spot_desired_nodes_count" {
  description = "The number of spot Amazon EC2 instances that should be running in the autoscaling group"
  type        = number
  default     = 1
}

variable "spot_min_nodes_count" {
  description = "The minimum size of the spot autoscaling group"
  type        = number
  default     = 1
}

# Variables for on-demand pool
variable "demand_instance_types" {
  description = "AWS instance type to build nodes for on-demand pool"
  type        = list(any)
  default     = [{ instance_type = "r5.xlarge" }]
}

variable "demand_max_nodes_count" {
  description = "The maximum size of the on-demand autoscaling group"
  type        = number
  default     = 0
}

variable "demand_desired_nodes_count" {
  description = "The number of on-demand Amazon EC2 instances that should be running in the autoscaling group"
  type        = number
  default     = 0
}

variable "demand_min_nodes_count" {
  description = "The minimum size of the on-demand autoscaling group"
  type        = number
  default     = 0
}

variable "aws_auth_users" {
  description = "List of user maps to add to the aws-auth configmap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "aws_auth_roles" {
  description = "List of role maps to add to the aws-auth configmap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(any)
  default     = {}
}

# OIDC Identity provider
variable "cluster_identity_providers" {
  description = "Configuration for OIDC identity provider"
  type        = any
  default     = {}
}

# Atlantis IAM Role variables
variable "create_atlantis_iam_role" {
  description = "Enable or disable the creation of IAM role for Atlantis"
  type        = bool
  default     = false
}

variable "atlantis_role_name" {
  description = "The AWS IAM role name for Atlantis"
  type        = string
  default     = "Atlantis"
}
