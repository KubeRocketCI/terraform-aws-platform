output "argocd_irsa_iam_role_arn" {
  description = "ARN of ArgoCD Master IAM role"
  value       = module.argocd_irsa.iam_role_arn
}

output "argocd_agent_role_iam_role_arn" {
  description = "ARN of ArgoCD Agent IAM role"
  value       = try(aws_iam_role.argocd_agent_role[0].arn, "")
}
