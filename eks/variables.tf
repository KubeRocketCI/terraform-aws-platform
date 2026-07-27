variable "region" {
  description = "The AWS region to deploy the cluster into (e.g. eu-central-1)"
  type        = string
  default     = ""
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.34"
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

variable "create_cd_pipeline_operator_irsa" {
  type    = bool
  default = false
}

variable "create_argocd_irsa" {
  type    = bool
  default = false
}

variable "cd_pipeline_operator_agent_role_arn" {
  description = "ARN of the CD Pipeline Operator Agent IAM role in account B"
  type        = string
  default     = ""
}

variable "cd_pipeline_operator_irsa_role_arn" {
  description = "ARN of the CD Pipeline Operator IRSA role in account A"
  type        = string
  default     = ""
}

variable "argocd_agent_role_arn" {
  description = "ARN of the ArgoCD Agent IAM role in account B"
  type        = string
  default     = ""
}

variable "argocd_irsa_role_arn" {
  description = "ARN of the ArgoCD IRSA role in account A"
  type        = string
  default     = ""
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

variable "create_schedule" {
  description = "Enable or disable the creation of a schedules for the Auto Scaling Groups"
  type        = bool
  default     = true
}

variable "admin_role_prefix" {
  description = "Kubernetes admin, based on AWS role prefix. Default: AWSReservedSSO_AdministratorAccess"
  type        = string
  default     = "AWSReservedSSO_AdminUser"
}

# nginx-ingress -> Envoy Gateway migration -------------------------------------
# The two variables below are a related pair and are kept together on purpose.
# Apply them in two steps for a zero-downtime cutover:
#   1. envoy_gateway_enabled = true       provisions the Envoy Gateway data-plane
#      target group on the existing ingress ALB and registers the node ASGs on it.
#      Nothing is routed to it yet, so it is safe to apply alone; wait for the target
#      group to become healthy.
#   2. platform_default_gateway = "envoy" flips the ALB default :443 action onto that
#      target group. It only takes effect once envoy_gateway_enabled is true. The
#      in-cluster nginx-fallback catch-all HTTPRoute then sends any host that still
#      lacks its own HTTPRoute back to nginx-ingress.
# To roll back, reverse the order: set platform_default_gateway = "nginx" first.
variable "envoy_gateway_enabled" {
  description = "Provision the Envoy Gateway data-plane target group (NodePort 32180) on the existing ingress ALB and register the node ASGs on it. No new load balancer is created and no traffic reaches it until platform_default_gateway = \"envoy\". Prerequisite for platform_default_gateway: enable this first and wait for the target group to become healthy before flipping the default action."
  type        = bool
  default     = false
}

variable "platform_default_gateway" {
  description = "Which data plane the ingress ALB default :443 action forwards to. \"nginx\" (default) keeps today's behaviour; \"envoy\" flips the default onto the Envoy Gateway data-plane target group so every host hits Envoy first, and any host that only has an Ingress (no HTTPRoute) falls through to nginx-ingress via the in-cluster nginx-fallback catch-all HTTPRoute (ingress-nginx add-on). Only takes effect when envoy_gateway_enabled = true, whose target group it forwards to; set that first and confirm the target group is healthy before setting \"envoy\"."
  type        = string
  default     = "nginx"

  validation {
    condition     = contains(["nginx", "envoy"], var.platform_default_gateway)
    error_message = "platform_default_gateway must be either \"nginx\" or \"envoy\"."
  }
}
