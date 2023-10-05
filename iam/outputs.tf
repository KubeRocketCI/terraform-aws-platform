output "kaniko_iam_role_arn" {
  description = "IAM role arn for kaniko"
  value       = module.kaniko_iam_role.kaniko_iam_role_arn
}

output "kaniko_iam_role_name" {
  description = "IAM role name for kaniko"
  value       = module.kaniko_iam_role.kaniko_iam_role_name
}

output "deployer_iam_role_arn" {
  description = "IAM role arn for EKS cluster deployment"
  value       = module.deployer_iam_role.deployer_iam_role_arn
}

output "deployer_iam_role_name" {
  description = "IAM role name for EKS cluster deployment"
  value       = module.deployer_iam_role.deployer_iam_role_name
}

