variable "create_iam_kaniko" {
  description = "Whether to create IAM role for Kaniko pod"
  type        = bool
  default     = false
}

variable "create_iam_worker_group" {
  description = "Whether to create IAM role for worker group"
  type        = bool
  default     = false
}

variable "region" {
  description = "The AWS region to deploy the cluster into, e.g. eu-central-1"
  type        = string
}

variable "tenant_name" {
  description = "The name of the tenant that is used for tagging resources. Match the [a-z0-9_-]"
  type        = string
}

variable "kaniko_role_name" {
  description = "User defined Kaniko IAM role name to create"
  type        = string
  default     = ""
}

variable "worker_group_role_name" {
  description = "User defined worker group IAM role name to create"
  type        = string
  default     = ""
}

variable "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  type        = string
  default     = ""
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  type        = string
  default     = ""
}

variable "namespace" {
  description = "The namespace where tenant resources are deployed"
  type        = string
  default     = "tenant"
}

variable "attach_worker_cni_policy" {
  description = "Whether to attach the Amazon managed `AmazonEKS_CNI_Policy` IAM policy to the created worker IAM role. WARNING: If set `false` the permissions must be assigned to the `aws-node` DaemonSet pods via another method or nodes will not be able to join the cluster"
  type        = bool
  default     = true
}

variable "attach_worker_efs_policy" {
  description = "Whether to attach the Customer managed `EFSProvisionerPolicy` IAM policy to the created worker IAM role"
  type        = bool
  default     = true
}

variable "workers_additional_policies" {
  description = "Additional policies arns to be added to workers"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(any)
  default     = {}
}
