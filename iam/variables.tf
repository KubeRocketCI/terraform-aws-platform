variable "region" {
  description = "The AWS region to deploy the cluster into, e.g. eu-central-1"
  type        = string
}

variable "deployer_role_name" {
  description = "The AWS IAM role name for EKS cluster deployment"
  type        = string
  default     = "KRCIDeployerRole"
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

# Trust policy of the deployer role ----------------------------------------------
# The defaults are the unrestricted values, the whole account and the EC2 service:
# a narrower default would change the role of every installation that does not set
# the variable. terraform plan warns while one is in use. The role needs at least one
# of the three sources of trust.
variable "deployer_role_trust_account" {
  description = "Trust the whole AWS account: every identity of it whose own IAM policy allows sts:AssumeRole on the role."
  type        = bool
  default     = true
  nullable    = false
}

variable "deployer_role_trust_ec2" {
  description = "Let EC2 instances assume the deployer role. Needed only when Terraform runs on an instance that carries the role."
  type        = bool
  default     = true
  nullable    = false
}

variable "deployer_role_trusted_principal_arns" {
  description = "IAM roles and users that may assume the deployer role, e.g. the role of the administrators and the Atlantis role. They must exist. With deployer_role_trust_account set to false, an identity that runs Terraform and is not listed is denied on its next run."
  type        = list(string)
  default     = []
  nullable    = false

  validation {
    condition     = alltrue([for arn in var.deployer_role_trusted_principal_arns : can(regex("^arn:aws[a-z-]*:iam::[0-9]{12}:(root|(role|user)/[A-Za-z0-9+=,.@_/-]+)$", arn))])
    error_message = "deployer_role_trusted_principal_arns must be a list of IAM role, user or account ARNs without wildcards, e.g. \"arn:aws:iam::012345678910:role/Atlantis\"."
  }
}
