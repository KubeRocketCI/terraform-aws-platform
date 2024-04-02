locals {
  tags = merge(
    var.tags,
    {
      "user:tag" = var.platform_name
    },
  )
  cluster_name = var.platform_name
  # we enable IRSA for ArgoCD Master only in case when it is enabled and we have at least one Agent role name in the list
  argocd_master_is_enabled = var.argocd_master_enabled && length(var.argocd_master_role_name_list) > 0
}
