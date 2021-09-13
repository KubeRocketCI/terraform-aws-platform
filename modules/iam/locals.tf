locals {
  aws_account_id = data.aws_caller_identity.current.account_id

  oidc_issuer_url           = trimprefix(var.cluster_oidc_issuer_url, "https://")
  kaniko_role_name_template = "AWSIRSA${replace(format("%s%s", title(var.tenant_name), title(var.namespace)), "-", "")}Kaniko"
  kaniko_role_name          = var.kaniko_role_name != "" ? var.kaniko_role_name : local.kaniko_role_name_template

  ec2_principal                   = "ec2.${data.aws_partition.current.dns_suffix}"
  policy_arn_prefix               = "arn:${data.aws_partition.current.partition}:iam::aws:policy"
  worker_group_role_name_template = "ServiceRoleForEKS${replace(title(var.tenant_name), "-", "")}WorkerNode"
  worker_group_role_name          = var.worker_group_role_name != "" ? var.worker_group_role_name : local.worker_group_role_name_template
}
