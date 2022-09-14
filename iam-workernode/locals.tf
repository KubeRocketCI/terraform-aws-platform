locals {
  aws_account_id = data.aws_caller_identity.current.account_id

  ec2_principal          = "ec2.${data.aws_partition.current.dns_suffix}"
  policy_arn_prefix      = "arn:${data.aws_partition.current.partition}:iam::aws:policy"
  worker_group_role_name = "ServiceRoleForEKS${replace(title(var.platform_name), "-", "")}WorkerNode"
}
