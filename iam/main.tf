module "deployer_iam_role" {
  source = "./iam-deployer"

  create_iam_deployer = var.create_iam_deployer

  deployer_role_name                  = var.deployer_role_name
  iam_permissions_boundary_policy_arn = var.iam_permissions_boundary_policy_arn
  tags                                = var.tags
}

module "kaniko_iam_role" {
  source = "./kaniko"

  create_iam_kaniko = var.create_iam_kaniko

  region                  = var.region
  cluster_oidc_issuer_url = var.cluster_oidc_issuer_url
  oidc_provider_arn       = var.oidc_provider_arn
  namespace               = var.namespace
  tags                    = var.tags
  kaniko_role_name        = var.kaniko_role_name
}
