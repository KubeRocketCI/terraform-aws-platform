locals {
  tags = merge(
    var.tags,
    {
      "user:tag" = var.platform_name
    },
  )
  cluster_name              = var.platform_name
  cluster_security_group_id = data.aws_security_group.default.id
}
