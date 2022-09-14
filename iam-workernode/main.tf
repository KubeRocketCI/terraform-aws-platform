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
  name_prefix = local.worker_group_role_name
  role        = aws_iam_role.workers.name

  tags = merge(var.tags, tomap({ "Name" = local.worker_group_role_name }))

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "workers" {
  name                  = local.worker_group_role_name
  description           = "IAM role to be used by worker group nodes"
  assume_role_policy    = data.aws_iam_policy_document.workers_assume_role_policy.json
  permissions_boundary  = var.iam_permissions_boundary_policy_arn
  force_detach_policies = true
  tags                  = merge(var.tags, tomap({ "Name" = local.worker_group_role_name }))
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKSWorkerNodePolicy" {
  policy_arn = "${local.policy_arn_prefix}/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKS_CNI_Policy" {
  policy_arn = "${local.policy_arn_prefix}/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "workers_AmazonSSMManagedInstanceCore" {
  policy_arn = "${local.policy_arn_prefix}/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = aws_iam_policy.workers_amazon_ec2_container_registry_read_only.arn
  role       = aws_iam_role.workers.name
}

resource "aws_iam_policy" "workers_amazon_ec2_container_registry_read_only" {
  name        = "${replace(title(var.platform_name), "-", "")}EC2ContainerRegistryReadOnly"
  description = "The read-only policy for ${var.platform_name} tenant registry"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:DescribeRepositories",
                "ecr:ListImages",
                "ecr:DescribeImages",
                "ecr:BatchGetImage",
                "ecr:GetLifecyclePolicy",
                "ecr:GetLifecyclePolicyPreview",
                "ecr:ListTagsForResource",
                "ecr:DescribeImageScanFindings"
            ],
            "Resource": [
                "arn:aws:ecr:${var.region}:602401143452:repository/*",
                "arn:aws:ecr:${var.region}:${local.aws_account_id}:repository/*"
            ]
        }
    ]
}
EOF
}
