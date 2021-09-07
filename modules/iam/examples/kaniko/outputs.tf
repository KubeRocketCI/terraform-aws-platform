output "kaniko_role_arn" {
  description = "IAM role arn to be used by Kaniko pod"
  value       = module.kaniko_iam_role.kaniko_role_arn
}

output "kaniko_role_name" {
  description = "IAM role name to be used by Kaniko pod"
  value       = module.kaniko_iam_role.kaniko_role_name
}
