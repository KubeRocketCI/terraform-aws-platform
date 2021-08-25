resource "aws_security_group" "cidr_blocks" {
  name_prefix = "eks-cluster-sg-public-${var.platform_name}"
  description = "Whitelist NAT Gateway and customer IP ranges for ${var.platform_name} EKS cluster. Managed by Terraform"
  vpc_id      = var.create_vpc ? module.vpc.vpc_id : var.vpc_id
  tags        = merge(var.tags, map("Name", "${var.platform_name}-public-eks-cluster-sg"))
}

resource "aws_security_group_rule" "nat_gw_http" {
  for_each          = toset(local.nat_public_cidrs)
  description       = "NAT Gateway public ips list"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [each.value]
  ipv6_cidr_blocks  = null
  security_group_id = aws_security_group.cidr_blocks.id
}

resource "aws_security_group_rule" "nat_gw_https" {
  for_each          = toset(local.nat_public_cidrs)
  description       = "NAT Gateway public ips list"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [each.value]
  ipv6_cidr_blocks  = null
  security_group_id = aws_security_group.cidr_blocks.id
}

resource "aws_security_group_rule" "customer" {
  count             = length(var.ingress_cidr_blocks) > 0 ? 1 : 0
  description       = "Customer ip range"
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = var.ingress_cidr_blocks
  ipv6_cidr_blocks  = null
  security_group_id = aws_security_group.cidr_blocks.id
}

resource "aws_security_group_rule" "workers_egress_internet" {
  description       = "Allow nodes all egress to the Internet"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = null
  security_group_id = aws_security_group.cidr_blocks.id
}

resource "aws_security_group" "prefix_list" {
  count       = length(var.ingress_prefix_list_ids)
  name_prefix = "eks-cluster-sg-public-${var.platform_name}"
  description = var.ingress_prefix_list_ids[count.index]["description"]
  vpc_id      = var.create_vpc ? module.vpc.vpc_id : var.vpc_id

  ingress = [
    {
      description      = var.ingress_prefix_list_ids[count.index]["description"]
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = null
      ipv6_cidr_blocks = null
      prefix_list_ids  = [var.ingress_prefix_list_ids[count.index]["public_prefix_id"]]
      security_groups  = null
      self             = true
    }
  ]

  egress = [
    {
      description      = "Allow nodes all egress to the Internet"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  tags = merge(var.tags, map("Name", "${var.platform_name}-${var.ingress_prefix_list_ids[count.index]["description"]}"))
}
