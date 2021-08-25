# EKS cluster variables
variable "aws_account_id" {
  description = "The AWS account id where EKS cluster deployed, e.g. 012345678910"
  type        = string
}

variable "region" {
  description = "The AWS region where EKS cluster deployed, e.g. eu-central-1"
  type        = string
}

variable "platform_name" {
  description = "The name of the cluster that is used for tagging resources."
  type        = string
}

variable "platform_domain_name" {
  description = "The name of existing DNS zone where EKS cluster deployed"
  type        = string
}

variable "platform_cidr" {
  description = "The default IP/network address of an external Load balancer."
  type        = string
}

# EDP configuration
variable "edp_helm_version" {
  description = "Specify the exact EDP helm chart version to install. If this is not specified, the latest version is installed."
  type        = string
}

variable "edp_helm_repo" {
  description = "Repository URL where to locate the requested EDP chart."
  type        = string
  default     = "https://chartmuseum.demo.edp-epam.com/"
}

variable "web_console_url" {
  description = "EKS cluster WEB console endpoint. The key of the clusters[0].cluster.server value in kubeconfig file of the deployed EKS cluster."
  type        = string
}

variable "admins" {
  description = "EDP admin users."
  type        = list(any)
}

variable "developers" {
  description = "EDP developer users."
  type        = list(any)
}

variable "kaniko_role_arn" {
  description = "Kaniko IAM role."
  type        = string
}

# Ingress configuration
variable "ingress_helm_version" {
  description = "Specify the exact NGINX Ingress Controller helm chart version to install. If this is not specified, the latest version is installed."
  type        = string
}

variable "ingress_helm_repo" {
  description = "Repository URL where to locate the requested NGINX Ingress Controller chart."
  type        = string
  default     = "https://kubernetes.github.io/ingress-nginx"
}

# Keycloak configuration
variable "keycloak_helm_version" {
  description = "Specify the exact Keycloak helm chart version to install. If this is not specified, the latest version is installed."
  type        = string
}

variable "keycloak_helm_repo" {
  description = "Repository URL where to locate the requested Keycloak chart."
  type        = string
  default     = "https://codecentric.github.io/helm-charts"
}

variable "keycloak_name" {
  description = "Keycloak-operator first level domain name."
  type        = string
  default     = "keycloak"
}

variable "keycloak_image_tag" {
  description = "Keycloak-operator image tag to deploy."
  type        = string
}

# Kiosk configuration
variable "kiosk_helm_version" {
  description = "Specify the exact Kiosk helm chart version to install. If this is not specified, the latest version is installed."
  type        = string
}

variable "kiosk_helm_repo" {
  description = "Repository URL where to locate the requested Kiosk chart."
  type        = string
  default     = "https://charts.devspace.sh/"
}

# Sensitive data
variable "keycloak_admin_username" {
  description = "Username for Keycloak admin user in the edp namespace."
  type        = string
}

variable "keycloak_admin_password" {
  description = "Password for Keycloak admin user in the edp namespace."
  type        = string
}

variable "super_admin_db_username" {
  description = "Username for EDP administrative access to database."
  type        = string
}

variable "super_admin_db_password" {
  description = "Password for EDP administrative access to database."
  type        = string
}

variable "db_admin_console_username" {
  description = "Username for EDP tenant database user."
  type        = string
}

variable "db_admin_console_password" {
  description = "Password for EDP tenant database user."
  type        = string
}

variable "keycloak_pg_pass" {
  description = "Password for Keycloak PostgreSQL admin password."
  type        = string
}
