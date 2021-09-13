output "lb_security_group_ids" {
  description = "Security group IDs should be attached to external LB."
  value       = local.lb_security_group_ids
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "default_security_group_id" {
  description = "Default security group id."
  value       = local.default_security_group_id
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`."
  value       = module.eks.oidc_provider_arn
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer."
  value       = module.eks.cluster_oidc_issuer_url
}

output "worker_group_instance_profile_names" {
  description = "Created IAM instance profiles names to attach to worker group nodes"
  value = var.extended_outputs ? tomap({
    for k, v in module.iam_tenants_worker_groups : k => v.worker_group_instance_profile_name
  }) : {}
}

output "kaniko_role_names" {
  description = "Created IAM roles names to be used by Kaniko pod"
  value = var.extended_outputs ? tomap({
    for k, v in module.iam_tenants_kaniko : k => v.kaniko_role_name
  }) : {}
}

output "worker_groups_launch_template_merged" {
  description = "Complete list of worker groups launch templates. Define extended_outputs=true to show in outputs"
  value       = try(var.extended_outputs ? local.worker_groups_launch_template_merged : tolist(false), [])
}
