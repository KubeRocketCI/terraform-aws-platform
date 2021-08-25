resource "aws_efs_file_system" "platform" {
  tags = merge(var.tags, map("Name", var.platform_name))
}

resource "aws_efs_mount_target" "platform" {
  count           = length(var.create_vpc ? module.vpc.private_subnets : var.private_subnets_id)
  file_system_id  = aws_efs_file_system.platform.id
  subnet_id       = element(var.create_vpc ? module.vpc.private_subnets : var.private_subnets_id, count.index)
  security_groups = [local.default_security_group_id]
}
