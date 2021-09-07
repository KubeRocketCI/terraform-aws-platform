output "kaniko_role_arn" {
  description = "IAM role arn to be used by Kaniko pod"
  value       = aws_iam_role.kaniko[0].arn
}

output "kaniko_role_name" {
  description = "IAM role name to be used by Kaniko pod"
  value       = aws_iam_role.kaniko[0].name
}
