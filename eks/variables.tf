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

# Scope of the IAM roles for ServiceAccounts -------------------------------------
# The defaults are the unrestricted values: a narrower default would change the roles
# of every installation that does not set the variable. terraform plan warns while one
# is in use.
# A ServiceAccount is "<namespace>:<name>" with * and ? as wildcards; a * for the
# namespace admits that name from every namespace. IAM limits a trust policy to 2,048
# characters by default, so a long list needs name patterns.
variable "external_secrets_service_accounts" {
  description = "ServiceAccounts that may assume the External Secrets Operator role, e.g. [\"krci:externalsecrets-aws\"]. Every SecretStore that authenticates through the role needs its ServiceAccount listed or matched, the ones of add-ons included. The default admits every ServiceAccount of the cluster."
  type        = list(string)
  default     = ["*"]
  nullable    = false

  validation {
    condition     = length(var.external_secrets_service_accounts) > 0 && alltrue([for sa in var.external_secrets_service_accounts : sa == "*" || can(regex("^[a-z0-9*?-]+:[a-z0-9*?.-]+$", sa))])
    error_message = "external_secrets_service_accounts must be [\"*\"] or a non-empty list of \"<namespace>:<name>\" items without the \"system:serviceaccount:\" prefix: lowercase letters, digits and '-', in the name also '.', with * and ? as wildcards."
  }
}

variable "external_secrets_secrets_manager_arns" {
  description = "Secrets Manager secrets the External Secrets Operator role may read, e.g. [\"arn:aws:secretsmanager:eu-central-1:012345678910:secret:/edp/*\"]. At least one ARN is required, also when Secrets Manager is not used. The default admits every secret."
  type        = list(string)
  default     = ["arn:aws:secretsmanager:*:*:secret:*"]
  nullable    = false

  validation {
    condition     = length(var.external_secrets_secrets_manager_arns) > 0 && alltrue([for arn in var.external_secrets_secrets_manager_arns : can(regex("^arn:aws[a-z-]*:secretsmanager:[a-z0-9*?-]+:[0-9*?]+:secret:[A-Za-z0-9/_+=.@!*?-]+$", arn))])
    error_message = "external_secrets_secrets_manager_arns must be a non-empty list of Secrets Manager secret ARNs, e.g. \"arn:aws:secretsmanager:eu-central-1:012345678910:secret:/edp/*\"."
  }
}

variable "external_secrets_kms_key_arns" {
  description = "KMS keys the External Secrets Operator role may decrypt with: the customer managed keys that encrypt the parameters and secrets of the platform, or [] when they are encrypted with AWS managed keys. The default admits every key."
  type        = list(string)
  default     = ["arn:aws:kms:*:*:key/*"]
  nullable    = false

  validation {
    condition     = alltrue([for arn in var.external_secrets_kms_key_arns : can(regex("^arn:aws[a-z-]*:kms:[a-z0-9*?-]+:[0-9*?]+:key/[A-Za-z0-9*?-]+$", arn))])
    error_message = "external_secrets_kms_key_arns must be a list of KMS key ARNs, e.g. \"arn:aws:kms:eu-central-1:012345678910:key/1234abcd-12ab-34cd-56ef-1234567890ab\"."
  }
}

variable "kaniko_service_accounts" {
  description = "ServiceAccounts that may assume the Kaniko role: the ones the build pipelines run as, e.g. [\"krci:tekton\"]. The default admits every ServiceAccount of the cluster."
  type        = list(string)
  default     = ["*"]
  nullable    = false

  validation {
    condition     = length(var.kaniko_service_accounts) > 0 && alltrue([for sa in var.kaniko_service_accounts : sa == "*" || can(regex("^[a-z0-9*?-]+:[a-z0-9*?.-]+$", sa))])
    error_message = "kaniko_service_accounts must be [\"*\"] or a non-empty list of \"<namespace>:<name>\" items without the \"system:serviceaccount:\" prefix: lowercase letters, digits and '-', in the name also '.', with * and ? as wildcards."
  }
}

variable "kaniko_repository_actions" {
  description = "IAM actions the Kaniko role may run on the ECR repositories of the region, next to describing and creating repositories and the login token, which it always has. Pipelines that only push and pull need the actions eks/example.tfvars lists. The default allows every ECR action, the deletion of repositories and images included; its cloudtrail:LookupEvents entry has no effect on a repository."
  type        = list(string)
  default     = ["ecr:*", "cloudtrail:LookupEvents"]
  nullable    = false

  validation {
    condition     = length(var.kaniko_repository_actions) > 0 && alltrue([for action in var.kaniko_repository_actions : can(regex("^[A-Za-z0-9-]+:[A-Za-z0-9*?]+$", action))])
    error_message = "kaniko_repository_actions must be a non-empty list of IAM actions, e.g. \"ecr:PutImage\"."
  }
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
