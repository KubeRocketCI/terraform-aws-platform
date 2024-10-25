#---------------------------------------------#
# ArgoCD Master Deployment
#---------------------------------------------#
variable "argocd_master_enabled" {
  description = "Enable or disable Argo CD IRSA. If enabled, then IRSA role is created and should be assigned to Argo CD Server and Controller"
  type        = bool
  default     = false
}

variable "argocd_master_role_name_list" {
  description = "The list of IAM roles to be assumed by Argo CD Master"
  type        = list(string)
  default     = []
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC provider for the EKS cluster"
  type        = string
  default     = ""
}

#---------------------------------------------#
# ArgoCD Agent Deployment
#---------------------------------------------#
variable "argocd_agent_enabled" {
  description = "Enable or disable Argo CD Agent. This flag will create IAM role for Argo CD Agent and add it to EKS cluster as kubernetes admin"
  type        = bool
  default     = true
}

variable "argocd_agent_argocd_master_role_arn" {
  description = "The ARN of the ArgoCD Master IAM, that is going to assume the ArgoCD Agent role"
  type        = string
  default     = ""
}

variable "argocd_agent_role_name" {
  description = "The name of IAM role to be assumed by Argo CD Master"
  type        = string
  default     = "EDPArgoCDClusterAdmin"
}

#---------------------------------------------#
# Common variables
#---------------------------------------------#
variable "platform_name" {
  description = "The name of the cluster that is used for tagging resources"
  type        = string
  default     = ""
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

variable "role_permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for IAM role"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(any)
  default     = {}
}
