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
