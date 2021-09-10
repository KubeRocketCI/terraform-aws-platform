locals {
  ec2_principal                   = "ec2.${data.aws_partition.current.dns_suffix}"
  policy_arn_prefix               = "arn:${data.aws_partition.current.partition}:iam::aws:policy"
  worker_group_role_name_template = "ServiceRoleForEKS${replace(title(var.tenant_name), "-", "")}WorkerNode"
  worker_group_role_name          = var.worker_group_role_name != "" ? var.worker_group_role_name : local.worker_group_role_name_template
}

data "aws_iam_policy_document" "workers_assume_role_policy" {
  statement {
    sid = "EKSWorkerAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = [local.ec2_principal]
    }
  }
}

resource "aws_iam_instance_profile" "workers" {
  count = var.create_iam_worker_group ? 1 : 0
  name  = local.worker_group_role_name
  role  = aws_iam_role.workers[0].name

  tags = merge(var.tags, map("Name", local.worker_group_role_name))

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "workers" {
  count                 = var.create_iam_worker_group ? 1 : 0
  name                  = local.worker_group_role_name
  description           = "IAM role to be used by worker group nodes"
  assume_role_policy    = data.aws_iam_policy_document.workers_assume_role_policy.json
  force_detach_policies = true
  tags                  = merge(var.tags, map("Name", local.worker_group_role_name))
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKSWorkerNodePolicy" {
  count      = var.create_iam_worker_group ? 1 : 0
  policy_arn = "${local.policy_arn_prefix}/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.workers[0].name
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKS_CNI_Policy" {
  count      = var.create_iam_worker_group && var.attach_worker_cni_policy ? 1 : 0
  policy_arn = "${local.policy_arn_prefix}/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.workers[0].name
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEC2ContainerRegistryReadOnly" {
  count      = var.create_iam_worker_group ? 1 : 0
  policy_arn = "${local.policy_arn_prefix}/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.workers[0].name
}

resource "aws_iam_role_policy_attachment" "workers_AmazonSSMManagedInstanceCore" {
  count      = var.create_iam_worker_group ? 1 : 0
  policy_arn = "${local.policy_arn_prefix}/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.workers[0].name
}

resource "aws_iam_role_policy_attachment" "workers_additional_policies" {
  count      = var.create_iam_worker_group ? length(var.workers_additional_policies) : 0
  policy_arn = var.workers_additional_policies[count.index]
  role       = aws_iam_role.workers[0].name
}

resource "aws_iam_role_policy_attachment" "workers_efs_provisioner" {
  count      = var.create_iam_worker_group && var.attach_worker_efs_policy ? 1 : 0
  policy_arn = aws_iam_policy.workers_efs_provisioner[0].arn
  role       = aws_iam_role.workers[0].name
}

resource "aws_iam_policy" "workers_efs_provisioner" {
  count       = var.create_iam_worker_group && var.attach_worker_efs_policy ? 1 : 0
  name        = "${replace(title(var.tenant_name), "-", "")}EFSProvisionerPolicy"
  description = "The policy for EFS Provisioner for ${var.tenant_name} tenant"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:DescribeAccessPoints",
        "elasticfilesystem:DescribeFileSystems"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:CreateAccessPoint"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "aws:RequestTag/efs.csi.aws.com/cluster": "true"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "elasticfilesystem:DeleteAccessPoint",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/efs.csi.aws.com/cluster": "true"
        }
      }
    }
  ]
}
EOF
}
