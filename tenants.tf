module "iam_tenants_worker_groups" {
  source   = "./modules/iam/"
  for_each = var.tenants

  create_iam_worker_group = lookup(var.tenants[each.key], "create_iam_worker_group", local.tenants_defaults["create_iam_worker_group"])

  tenant_name = lookup(var.tenants[each.key], "name", local.tenants_defaults["name"])
  region      = var.region
  namespace   = lookup(var.tenants[each.key], "namespace", lookup(var.tenants[each.key], "name", local.tenants_defaults["name"]))

  attach_worker_cni_policy = lookup(var.tenants[each.key], "attach_worker_cni_policy", local.tenants_defaults["attach_worker_cni_policy"])
  attach_worker_efs_policy = lookup(var.tenants[each.key], "attach_worker_efs_policy", local.tenants_defaults["attach_worker_efs_policy"])

  tags = merge(
    var.tags,
    {
      for tag in lookup(var.tenants[each.key], "tags", local.tenants_defaults["tags"]) :
      tag["key"] => tag["value"]
    }
  )
}

module "iam_tenants_kaniko" {
  source   = "./modules/iam/"
  for_each = var.tenants

  create_iam_kaniko = var.enable_irsa ? lookup(var.tenants[each.key], "create_iam_kaniko", local.tenants_defaults["create_iam_kaniko"]) : false

  tenant_name = lookup(var.tenants[each.key], "name", local.tenants_defaults["name"])
  region      = var.region
  namespace   = lookup(var.tenants[each.key], "namespace", lookup(var.tenants[each.key], "name", local.tenants_defaults["name"]))

  oidc_provider_arn       = module.eks.oidc_provider_arn
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url

  tags = merge(
    var.tags,
    {
      for tag in lookup(var.tenants[each.key], "tags", local.tenants_defaults["tags"]) :
      tag["key"] => tag["value"]
    }
  )
}
