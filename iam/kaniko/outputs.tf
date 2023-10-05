output "kaniko_iam_role_arn" {
  description = "IAM role arn for EKS cluster deployment"
  value       = aws_iam_role.kaniko[*].arn
}

output "kaniko_iam_role_name" {
  description = "IAM role name for EKS cluster deployment"
  value       = aws_iam_role.kaniko[*].name
}
