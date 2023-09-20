variable "create_elb" {
  description = "Whether to create ELB for Gerrit. The variable create_cluster = true is required"
  type        = bool
  default     = true
}

variable "region" {
  description = "The AWS region to deploy the cluster into (e.g. eu-central-1)"
  type        = string
}

variable "role_arn" {
  description = "The AWS IAM role arn to assume for running terraform (e.g. arn:aws:iam::012345678910:role/EKSDeployerRole)"
  type        = string
}

variable "platform_name" {
  description = "The name of the cluster that is used for tagging resources. Match the [a-z0-9_-]"
  type        = string
}

variable "platform_domain_name" {
  description = "The name of existing DNS zone for platform"
  type        = string
}

variable "infrastructure_public_security_group_ids" {
  description = "Security groups to be attached to infrastructure LB."
  type        = list(any)
}

variable "subnet_azs" {
  description = "Available zones of your future or existing subnets"
  type        = list(any)
  default     = []
}

variable "platform_cidr" {
  description = "CIRD of your future or existing VPC"
  type        = string
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

variable "ssl_policy" {
  description = "Predefined SSL security policy for ALB https listeners"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.22"
}

variable "key_name" {
  description = "The name of AWS ssh key to create and attach to all created nodes"
  type        = string
}

variable "enable_irsa" {
  description = "Whether to create OpenID Connect Provider for EKS to enable IRSA"
  type        = bool
  default     = false
}

variable "cluster_iam_role_name" {
  description = "A cluster IAM role name (not ARN) to run EKS cluster"
  type        = string
  default     = ""
}

variable "worker_iam_instance_profile_name" {
  description = "An instance profile name (not ARN) to run EKS worker nodes"
  type        = string
  default     = ""
}

variable "add_userdata" {
  description = "Additional userdata for launch template"
  type        = string
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_roles" {
  description = "Additional IAM Roles to add to the aws-auth configmap"
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
}

// Variables for demand pool
variable "demand_instance_types" {
  description = "AWS instance type to build nodes for demand pool"
  type        = list(any)
  default     = ["r5.large"]
}

variable "demand_max_nodes_count" {
  description = "Maximum demand nodes count in ASG"
  type        = number
  default     = 0
}

variable "demand_desired_nodes_count" {
  description = "Desired demand nodes count in ASG"
  type        = number
  default     = 0
}

variable "demand_min_nodes_count" {
  description = "Min on-demand nodes count in ASG" // Must be less or equal to desired_nodes_count
  type        = number
  default     = 0
}

// Variables for spot pool
variable "spot_instance_types" {
  description = "AWS instance type to build nodes for spot pool"
  type        = list(any)
  default     = ["r5.large", "m5.large", "t3.large"]
}

variable "spot_max_nodes_count" {
  description = "Maximum spot nodes count in ASG"
  type        = number
  default     = 0
}

variable "spot_desired_nodes_count" {
  description = "Desired spot nodes count in ASG"
  type        = number
  default     = 0
}

variable "spot_min_nodes_count" {
  description = "Desired spot nodes count in ASG"
  type        = number
  default     = 0
}
