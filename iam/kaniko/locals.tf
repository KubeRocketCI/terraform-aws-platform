locals {
  aws_account_id = data.aws_caller_identity.current.account_id

  oidc_issuer_url           = trimprefix(var.cluster_oidc_issuer_url, "https://")
  kaniko_role_name_template = "AWSIRSA${replace(format("%s", title(var.namespace)), "-", "")}Kaniko"
  kaniko_role_name          = var.kaniko_role_name != "" ? var.kaniko_role_name : local.kaniko_role_name_template
}
