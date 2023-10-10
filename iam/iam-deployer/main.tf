resource "aws_iam_role" "deployer" {
  count = var.create_iam_deployer ? 1 : 0

  name                  = var.deployer_role_name
  description           = "IAM role to assume in order to deploy and manage EKS cluster"
  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy.json
  force_detach_policies = true
  permissions_boundary  = var.iam_permissions_boundary_policy_arn

  inline_policy {
    name = "EKSDeployer"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "acm:*",
            "autoscaling:AttachInstances",
            "autoscaling:AttachLoadBalancers",
            "autoscaling:AttachLoadBalancerTargetGroups",
            "autoscaling:CreateAutoScalingGroup",
            "autoscaling:CreateLaunchConfiguration",
            "autoscaling:CreateOrUpdateTags",
            "autoscaling:DeleteAutoScalingGroup",
            "autoscaling:DeleteLaunchConfiguration",
            "autoscaling:DeleteScheduledAction",
            "autoscaling:DeleteTags",
            "autoscaling:Describe*",
            "autoscaling:DetachInstances",
            "autoscaling:DetachLoadBalancers",
            "autoscaling:DetachLoadBalancerTargetGroups",
            "autoscaling:PutScheduledUpdateGroupAction",
            "autoscaling:SetDesiredCapacity",
            "autoscaling:SetInstanceProtection",
            "autoscaling:SuspendProcesses",
            "autoscaling:UpdateAutoScalingGroup",
            "ec2:AllocateAddress",
            "ec2:AssignPrivateIpAddresses",
            "ec2:Associate*",
            "ec2:AttachInternetGateway",
            "ec2:AttachNetworkInterface",
            "ec2:AuthorizeSecurityGroupEgress",
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:CreateDefaultSubnet",
            "ec2:CreateDhcpOptions",
            "ec2:CreateEgressOnlyInternetGateway",
            "ec2:CreateInternetGateway",
            "ec2:CreateLaunchTemplate",
            "ec2:CreateLaunchTemplateVersion",
            "ec2:CreateNatGateway",
            "ec2:CreateNetworkInterface",
            "ec2:CreateRoute",
            "ec2:CreateRouteTable",
            "ec2:CreateSecurityGroup",
            "ec2:CreateSubnet",
            "ec2:CreateTags",
            "ec2:CreateVolume",
            "ec2:CreateVpc",
            "ec2:CreateVpcEndpoint",
            "ec2:DeleteDhcpOptions",
            "ec2:DeleteEgressOnlyInternetGateway",
            "ec2:DeleteInternetGateway",
            "ec2:DeleteKeyPair",
            "ec2:DeleteLaunchTemplate",
            "ec2:DeleteLaunchTemplateVersions",
            "ec2:DeleteNatGateway",
            "ec2:DeleteNetworkInterface",
            "ec2:DeleteRoute",
            "ec2:DeleteRouteTable",
            "ec2:DeleteSecurityGroup",
            "ec2:DeleteSubnet",
            "ec2:DeleteTags",
            "ec2:DeleteVolume",
            "ec2:DeleteVpc",
            "ec2:DeleteVpnGateway",
            "ec2:Describe*",
            "ec2:DetachInternetGateway",
            "ec2:DetachNetworkInterface",
            "ec2:DetachVolume",
            "ec2:Disassociate*",
            "ec2:GetLaunchTemplateData",
            "ec2:ImportKeyPair",
            "ec2:ModifyLaunchTemplate",
            "ec2:ModifySubnetAttribute",
            "ec2:ModifyVpcAttribute",
            "ec2:ModifyVpcEndpoint",
            "ec2:ReleaseAddress",
            "ec2:ReplaceRoute",
            "ec2:RevokeSecurityGroupEgress",
            "ec2:RevokeSecurityGroupIngress",
            "ec2:RunInstances",
            "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
            "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
            "eks:CreateAddon",
            "eks:CreateCluster",
            "eks:CreateFargateProfile",
            "eks:CreateNodegroup",
            "eks:DeleteAddon",
            "eks:DeleteCluster",
            "eks:DeleteFargateProfile",
            "eks:DeleteNodegroup",
            "eks:DescribeAddon",
            "eks:DescribeAddonVersions",
            "eks:DescribeCluster",
            "eks:DescribeFargateProfile",
            "eks:DescribeNodegroup",
            "eks:DescribeUpdate",
            "eks:ListAddons",
            "eks:ListClusters",
            "eks:ListFargateProfiles",
            "eks:ListNodegroups",
            "eks:ListTagsForResource",
            "eks:TagResource",
            "eks:UntagResource",
            "eks:UpdateAddon",
            "eks:UpdateClusterConfig",
            "eks:UpdateClusterVersion",
            "eks:UpdateNodegroupConfig",
            "eks:UpdateNodegroupVersion",
            "elasticfilesystem:*",
            "elasticloadbalancing:*",
            "iam:AddRoleToInstanceProfile",
            "iam:AttachRolePolicy",
            "iam:CreateInstanceProfile",
            "iam:CreateOpenIDConnectProvider",
            "iam:CreatePolicy",
            "iam:CreatePolicyVersion",
            "iam:CreateRole",
            "iam:CreateServiceLinkedRole",
            "iam:DeleteInstanceProfile",
            "iam:DeleteOpenIDConnectProvider",
            "iam:DeletePolicy",
            "iam:DeletePolicyVersion",
            "iam:DeleteRole",
            "iam:DeleteRolePolicy",
            "iam:DeleteServiceLinkedRole",
            "iam:DetachRolePolicy",
            "iam:GetInstanceProfile",
            "iam:GetOpenIDConnectProvider",
            "iam:GetPolicy",
            "iam:GetPolicyVersion",
            "iam:GetRole",
            "iam:GetRolePolicy",
            "iam:List*",
            "iam:PassRole",
            "iam:PutRolePolicy",
            "iam:RemoveRoleFromInstanceProfile",
            "iam:TagInstanceProfile",
            "iam:TagOpenIDConnectProvider",
            "iam:TagPolicy",
            "iam:TagRole",
            "iam:UnTagInstanceProfile",
            "iam:UntagOpenIDConnectProvider",
            "iam:UnTagPolicy",
            "iam:UnTagRole",
            "iam:UpdateAssumeRolePolicy",
            "kms:CreateAlias",
            "kms:CreateGrant",
            "kms:CreateKey",
            "kms:DeleteAlias",
            "kms:DescribeKey",
            "kms:GetKeyPolicy",
            "kms:GetKeyRotationStatus",
            "kms:ListAliases",
            "kms:ListResourceTags",
            "kms:ScheduleKeyDeletion",
            "logs:CreateLogGroup",
            "logs:DeleteLogGroup",
            "logs:DescribeLogGroups",
            "logs:ListTagsLogGroup",
            "logs:PutRetentionPolicy",
            "route53:*",
            "s3:*",
            "secretsmanager:*",
            "ssm:AddTagsToResource",
            "ssm:DeleteParameter",
            "ssm:DescribeParameters",
            "ssm:GetParameter",
            "ssm:GetParameters",
            "ssm:ListTagsForResource",
            "ssm:PutParameter",
            "wafv2:*",
            "autoscaling:StartInstanceRefresh",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

  inline_policy {
    name = "EKSIdentityProviderFullAccess"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "eks:DescribeIdentityProviderConfig",
            "eks:AssociateIdentityProviderConfig",
            "eks:ListIdentityProviderConfigs",
            "eks:DisassociateIdentityProviderConfig"
          ]
          Effect   = "Allow"
          Resource = "arn:aws:eks:*:${data.aws_caller_identity.current.account_id}:cluster/*"
        },
      ]
    })
  }

  tags = merge(var.tags, tomap({ "Name" = var.deployer_role_name }))
}
