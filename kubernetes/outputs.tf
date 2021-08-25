output "edp_config" {
  description = "EDP config generated for helm chart deployment"
  value       = helm_release.edp.values
}
