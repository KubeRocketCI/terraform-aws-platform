data "aws_iam_policy" "ssm" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "efs" {
  count       = var.manage_worker_iam_resources && var.create_cluster ? 1 : 0
  name        = "${var.platform_name}-efs-provisioner-policy"
  description = "The policy for EFS Provisioner"

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

resource "aws_iam_role_policy_attachment" "ssm" {
  count      = var.manage_worker_iam_resources && var.create_cluster ? 1 : 0
  role       = module.eks.worker_iam_role_name
  policy_arn = data.aws_iam_policy.ssm.arn
}

resource "aws_iam_role_policy_attachment" "efs" {
  count      = var.manage_worker_iam_resources && var.create_cluster ? 1 : 0
  role       = module.eks.worker_iam_role_name
  policy_arn = aws_iam_policy.efs[0].arn
}
