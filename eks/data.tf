data "aws_caller_identity" "current" {}

data "aws_route53_zone" "this" {
  name         = var.platform_domain_name
  private_zone = false
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = var.vpc_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = local.cluster_name
}

data "aws_iam_policy" "AmazonEC2ContainerRegistryReadOnly" {
  name = "AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_policy" "AmazonEKS_CNI_Policy" {
  name = "AmazonEKS_CNI_Policy"
}

data "aws_iam_policy" "AmazonEKSWorkerNodePolicy" {
  name = "AmazonEKSWorkerNodePolicy"
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

  }
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement           {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect = "Allow"
    principals {
      type       = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.eks.oidc_provider}"]
    }
    condition {
      test     = "StringEquals"
      variable = "${module.eks.cluster_oidc_issuer_url}:aud"
      values   = ["sts.amazonaws.com"]
    }


    condition {
      test     = "StringEquals"
      variable = "${module.eks.cluster_oidc_issuer_url}:sub"
      values   = ["system:serviceaccount:karpenter:karpenter"]
    }
  }
}
