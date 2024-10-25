## IAM Permissions

There are the minimum AWS IAM permissions required for an IAM user or IAM role to create an EKS cluster with the provided configuration.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "acm:*",
                "autoscaling:AttachInstances",
                "autoscaling:AttachLoadBalancers",
                "autoscaling:AttachLoadBalancerTargetGroups",
                "autoscaling:CreateAutoScalingGroup",
                "autoscaling:CreateLaunchConfiguration",
                "autoscaling:CreateOrUpdateTags",
                "autoscaling:DeleteAutoScalingGroup",
                "autoscaling:DeleteLaunchConfiguration",
                "autoscaling:DeleteTags",
                "autoscaling:Describe*",
                "autoscaling:DetachInstances",
                "autoscaling:DetachLoadBalancers",
                "autoscaling:DetachLoadBalancerTargetGroups",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:UpdateAutoScalingGroup",
                "autoscaling:SuspendProcesses",
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
                "ec2:ModifySubnetAttribute",
                "ec2:ModifyVpcAttribute",
                "ec2:ModifyVpcEndpoint",
                "ec2:ReleaseAddress",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
                "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
                "ec2:CreateLaunchTemplate",
                "ec2:CreateLaunchTemplateVersion",
                "ec2:DeleteLaunchTemplate",
                "ec2:DeleteLaunchTemplateVersions",
                "ec2:Describe*",
                "ec2:GetLaunchTemplateData",
                "ec2:ModifyLaunchTemplate",
                "ec2:RunInstances",
                "eks:CreateCluster",
                "eks:DeleteCluster",
                "eks:DescribeCluster",
                "eks:ListClusters",
                "eks:UpdateClusterConfig",
                "eks:UpdateClusterVersion",
                "eks:DescribeUpdate",
                "eks:TagResource",
                "eks:UntagResource",
                "eks:ListTagsForResource",
                "eks:CreateFargateProfile",
                "eks:DeleteFargateProfile",
                "eks:DescribeFargateProfile",
                "eks:ListFargateProfiles",
                "eks:CreateNodegroup",
                "eks:DeleteNodegroup",
                "eks:DescribeNodegroup",
                "eks:ListNodegroups",
                "eks:UpdateNodegroupConfig",
                "eks:UpdateNodegroupVersion",
                "elasticfilesystem:*",
                "elasticloadbalancing:*",
                "iam:AddRoleToInstanceProfile",
                "iam:AttachRolePolicy",
                "iam:CreateInstanceProfile",
                "iam:CreateOpenIDConnectProvider",
                "iam:CreateServiceLinkedRole",
                "iam:CreatePolicy",
                "iam:CreatePolicyVersion",
                "iam:CreateRole",
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
                "logs:CreateLogGroup",
                "logs:DescribeLogGroups",
                "logs:DeleteLogGroup",
                "logs:ListTagsLogGroup",
                "logs:PutRetentionPolicy",
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
                "route53:*",
                "s3:*"
            ],
            "Resource": "*"
        }
    ]
}
```

### How to use AWS IAM role

1. Create AWS IAM role with the permissions listed above in the AWS account where EKS cluster is going to be deployed, e.g. `arn:aws:iam::012345678910:role/KRCIDeployerRole`.
Put the main AWS account to the trusted entities to allow this role to be assumed, such as:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {"Service": "ec2.amazonaws.com"}
    },
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {"AWS": "arn:aws:iam::012345678910:root"}
    }
  ]
}
```

2. Create AWS IAM policy in the main AWS account to allow to assume the created IAM role.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": "arn:aws:iam::012345678910:role/KRCIDeployerRole"
        }
    ]
}
```

3. Example permisions boundary policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "IAMRoleManagement",
            "Effect": "Allow",
            "Action": [
                "iam:PutRolePermissionsBoundary",
                "iam:CreateRole",
                "iam:AttachRolePolicy",
                "iam:PutRolePolicy"
            ],
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "iam:PermissionsBoundary": "arn:aws:iam::*:policy/eo_role_boundary"
                }
            }
        },
        {
            "Sid": "DefaultRoleBoundary",
            "Effect": "Allow",
            "NotAction": [
                "iam:DeactivateMFADevice",
                "iam:CreateServiceSpecificCredential",
                "iam:DeleteAccessKey",
                "iam:UpdateOpenIDConnectProviderThumbprint",
                "iam:CreateRole",
                "iam:AttachRolePolicy",
                "iam:SetSecurityTokenServicePreferences",
                "iam:CreateLoginProfile",
                "iam:CreateAccountAlias",
                "iam:DeleteServerCertificate",
                "iam:UploadSSHPublicKey",
                "iam:ChangePassword",
                "iam:UpdateLoginProfile",
                "iam:UpdateServiceSpecificCredential",
                "iam:CreateGroup",
                "iam:RemoveClientIDFromOpenIDConnectProvider",
                "iam:UpdateUser",
                "iam:UpdateAccessKey",
                "iam:UpdateSSHPublicKey",
                "iam:UpdateServerCertificate",
                "iam:DeleteSigningCertificate",
                "iam:UpdateAccountPasswordPolicy",
                "iam:PutRolePermissionsBoundary",
                "iam:ResetServiceSpecificCredential",
                "iam:DeleteSSHPublicKey",
                "iam:CreateVirtualMFADevice",
                "iam:CreateSAMLProvider",
                "iam:DeleteRolePermissionsBoundary",
                "iam:CreateUser",
                "iam:CreateAccessKey",
                "iam:EnableMFADevice",
                "iam:ResyncMFADevice",
                "iam:DeleteAccountAlias",
                "iam:UpdateSAMLProvider",
                "iam:DeleteLoginProfile",
                "iam:UploadSigningCertificate",
                "iam:PutUserPermissionsBoundary",
                "budgets:*",
                "iam:DeleteUser",
                "iam:DeleteUserPermissionsBoundary",
                "iam:UploadServerCertificate",
                "iam:DeleteVirtualMFADevice",
                "ec2:AcceptReservedInstancesExchangeQuote",
                "iam:UpdateSigningCertificate",
                "iam:AddClientIDToOpenIDConnectProvider",
                "iam:DeleteServiceSpecificCredential",
                "iam:DeleteSAMLProvider"
            ],
            "Resource": "*"
        }
    ]
}
```

4. Attach the created IAM policy to the Principal who is going to deploy the cluster. It can be AWS IAM user group, IAM user or IAM role.

Moreover, it's supposed that the Jenkins instance will assume the provided IAM role to deploy the EKS cluster in a customer account.

5. Put the IAM role arn to the input variables in the `terraform.tfvars` file to assume it for EKS cluster deployment.

```
role_arn = "arn:aws:iam::012345678910:role/KRCIDeployerRole"
```

6. Run the Terraform to apply the changes.
