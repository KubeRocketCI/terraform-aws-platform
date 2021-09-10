output "kaniko_role_arn" {
  description = "IAM role arn to be used by Kaniko pod"
  value       = var.create_iam_kaniko ? aws_iam_role.kaniko[0].arn : ""
}

output "kaniko_role_name" {
  description = "IAM role name to be used by Kaniko pod"
  value       = var.create_iam_kaniko ? aws_iam_role.kaniko[0].name : ""
}

output "worker_group_role_arn" {
  description = "IAM role arn to be used by worker group nodes"
  value       = var.create_iam_worker_group ? aws_iam_role.workers[0].arn : ""
}

output "worker_group_role_name" {
  description = "IAM role name to be used by worker group nodes"
  value       = var.create_iam_worker_group ? aws_iam_role.workers[0].name : ""
}

output "worker_group_instance_profile_arn" {
  description = "IAM instance profile arn to attach to worker group nodes"
  value       = var.create_iam_worker_group ? aws_iam_instance_profile.workers[0].arn : ""
}

output "worker_group_instance_profile_name" {
  description = "IAM instance profile name to attach to worker group nodes"
  value       = var.create_iam_worker_group ? aws_iam_instance_profile.workers[0].name : ""
}
