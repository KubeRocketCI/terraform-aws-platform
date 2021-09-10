output "worker_group_role_arn" {
  description = "IAM role arn to be used by worker group nodes"
  value       = module.worker_group_iam_role.worker_group_role_arn
}

output "worker_group_role_name" {
  description = "IAM role name to be used by worker group nodes"
  value       = module.worker_group_iam_role.worker_group_role_name
}

output "worker_group_instance_profile_arn" {
  description = "IAM instance profile arn to attach to worker group nodes"
  value       = module.worker_group_iam_role.worker_group_instance_profile_arn
}

output "worker_group_instance_profile_name" {
  description = "IAM instance profile name to attach to worker group nodes"
  value       = module.worker_group_iam_role.worker_group_instance_profile_name
}
