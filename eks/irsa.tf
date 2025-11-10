##########################################################
#                   IRSA for CSI Driver                  #
##########################################################


module "aws_ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "6.1.0"

  name                 = "AWSIRSA_${replace(title(local.cluster_name), "-", "")}_EBS_CSI_Driver"
  permissions_boundary = var.role_permissions_boundary_arn
  use_name_prefix      = false
  policies = {
    AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.tags
}

##########################################################
#                   IRSA for CNI Driver                  #
##########################################################

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "6.1.0"

  name                 = "AWSIRSA_${replace(title(local.cluster_name), "-", "")}_VPC_CNI"
  permissions_boundary = var.role_permissions_boundary_arn
  use_name_prefix      = false

  create_policy         = false
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  policies = {
    AmazonEKS_CNI_Policy = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
  tags = local.tags
}

##########################################################
#            IRSA for External Secret Operator           #
##########################################################

module "externalsecrets_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.60.0"

  role_name                     = "AWSIRSA_${replace(title(local.cluster_name), "-", "")}_ExternalSecretOperatorAccess"
  assume_role_condition_test    = "StringLike"
  role_permissions_boundary_arn = var.role_permissions_boundary_arn

  attach_external_secrets_policy = true
  policy_name_prefix             = "AWSIRSA_${replace(title(local.cluster_name), "-", "")}"
  external_secrets_ssm_parameter_arns = [
    "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/edp/*"
  ]

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["*"]
    }
  }
  tags = local.tags
}

##########################################################
#                    IRSA for Kaniko                     #
##########################################################

module "kaniko_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "6.1.0"

  create = var.create_kaniko_iam_role

  name                 = "AWSIRSA_${replace(title(local.cluster_name), "-", "")}_KanikoAccess"
  trust_condition_test = "StringLike"
  use_name_prefix      = false

  policies = {
    policy = module.kaniko_iam_policy.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["*"]
    }
  }

  tags = local.tags
}

module "kaniko_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "6.1.0"

  create = var.create_kaniko_iam_role

  name        = "AWSIRSA_${replace(title(local.cluster_name), "-", "")}_KanikoAccess"
  path        = "/"
  description = "IAM policy granting access to ECR and CloudTrail for Kaniko"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:*",
          "cloudtrail:LookupEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/*"
      },
      {
        Action   = "ecr:GetAuthorizationToken"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ecr:DescribeRepositories",
          "ecr:CreateRepository"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/*"
      }
    ]
  })

  tags = local.tags
}

############################################################
#                   IRSA for CD Pipeline Operator          #
############################################################

# NOTE: The following resources should be created in AWS Account B (target/remote account) where the applications will be deployed.
# ref: https://docs.kuberocketci.io/docs/operator-guide/cd/deploy-application-in-remote-cluster-via-irsa
#
# resource "aws_eks_access_entry" "cd_pipeline_agent_access" {
#   count             = var.create_cd_pipeline_operator_irsa ? 1 : 0
#   cluster_name      = module.eks.cluster_name
#   principal_arn     = module.cd_pipeline_operator_agent_role.iam_role_arn
#   kubernetes_groups = ["cd-pipeline-operator"]
#   type              = "STANDARD"
# }
#
# resource "aws_eks_access_policy_association" "cd_pipeline_agent_policy" {
#   count         = var.create_cd_pipeline_operator_irsa ? 1 : 0
#   cluster_name  = module.eks.cluster_name
#   principal_arn = module.cd_pipeline_operator_agent_role.iam_role_arn
#   policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
#   access_scope {
#     type = "cluster"
#   }
# }

module "cd_pipeline_operator_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "6.1.0"

  create = var.create_cd_pipeline_operator_irsa

  name                 = "AWSIRSA_${replace(title(local.cluster_name), "-", "")}_CDPipelineOperator"
  trust_condition_test = "StringEquals"
  use_name_prefix      = false

  policies = {
    policy = module.cd_pipeline_operator_cross_account_assume_role_policy.arn
  }

  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = [
        "krci:edp-cd-pipeline-operator"
      ]
    }
  }

  tags = local.tags
}

module "cd_pipeline_operator_cross_account_assume_role_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "6.1.0"

  create = var.create_cd_pipeline_operator_irsa

  name        = "AWSIRSA_${replace(title(local.cluster_name), "-", "")}_CDPipelineAssume"
  path        = "/"
  description = "Policy allows to assume the CDPipelineAgent role in account B"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = var.cd_pipeline_operator_agent_role_arn
      }
    ]
  })

  tags = local.tags
}

# NOTE: The following resource should be created in AWS Account B (target/remote account) where the applications will be deployed.
# ref: https://docs.kuberocketci.io/docs/operator-guide/cd/deploy-application-in-remote-cluster-via-irsa
#
# module "cd_pipeline_operator_agent_role" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-role"
#   version = "6.1.0"
#
#   create            = var.create_cd_pipeline_operator_irsa
#   role_name         = "AWSIRSA_${replace(title(local.cluster_name), "-", "")}_CDPipelineAgent"
#   role_requires_mfa = false
#
#   trusted_role_arns = [
#     var.cd_pipeline_operator_irsa_role_arn
#   ]
#
#   tags = local.tags
# }

###############################################################
#                   IRSA for Argo CD                          #
###############################################################

# NOTE: The following resources should be created in AWS Account B (target/remote account) where the applications will be deployed.
# ref: https://docs.kuberocketci.io/docs/operator-guide/cd/deploy-application-in-remote-cluster-via-irsa
#
# resource "aws_eks_access_entry" "argocd_agent_access" {
#   count         = var.create_argocd_irsa ? 1 : 0
#   cluster_name  = module.eks.cluster_name
#   principal_arn = module.argocd_agent_role.iam_role_arn
#   type          = "STANDARD"
# }
#
# resource "aws_eks_access_policy_association" "argocd_agent_policy" {
#   count         = var.create_argocd_irsa ? 1 : 0
#   cluster_name  = module.eks.cluster_name
#   principal_arn = module.argocd_agent_role.iam_role_arn
#   policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
#   access_scope {
#     type = "cluster"
#   }
# }

module "argocd_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "6.1.0"

  create = var.create_argocd_irsa

  name                 = "AWSIRSA_${replace(title(local.cluster_name), "-", "")}_ArgoCDMaster"
  trust_condition_test = "StringLike"
  use_name_prefix      = false

  policies = {
    policy = module.argocd_cross_account_access_policy.arn
  }

  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = [
        "argocd:argocd-application-controller",
        "argocd:argocd-applicationset-controller",
        "argocd:argocd-server"
      ]
      audience = "sts.amazonaws.com"
    }
  }

  tags = local.tags
}

module "argocd_cross_account_access_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "6.1.0"

  create = var.create_argocd_irsa

  name        = "AWSIRSA_${replace(title(local.cluster_name), "-", "")}_ArgoCDMasterClusterAccess"
  path        = "/"
  description = "Policy allows to assume the ArgoCDAgentAccess role in account B"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Resource = [
          var.argocd_agent_role_arn
        ]
      }
    ]
  })

  tags = local.tags
}

# NOTE: The following resource should be created in AWS Account B (target/remote account) where the applications will be deployed.
# ref: https://docs.kuberocketci.io/docs/operator-guide/cd/deploy-application-in-remote-cluster-via-irsa
#
# module "argocd_agent_role" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-role"
#   version = "6.1.0"
#
#   create            = var.create_argocd_irsa
#   name         = "AWSIRSA_${replace(title(local.cluster_name), "-", "")}_ArgoCDAgentAccess"
#   role_requires_mfa = false
#
#   trusted_role_arns = [
#     var.argocd_irsa_role_arn
#   ]
#
#   tags = local.tags
# }

###############################################################
#                  IRSA for Karpenter                         #
###############################################################

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "21.3.1"

  cluster_name                  = var.platform_name
  iam_role_name                 = "KarpenterControllerRole-${var.platform_name}"
  iam_role_use_name_prefix      = false
  node_iam_role_name            = "KarpenterNodeRole-${var.platform_name}"
  node_iam_role_use_name_prefix = false

  create_pod_identity_association = false

  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = local.tags
}

##########################################################
#                    IRSA for Velero                    #
##########################################################
module "velero" {
  source  = "terraform-module/velero/kubernetes"
  version = "1.3.0"

  app_deploy    = false
  iam_deploy    = true
  iam_role_name = "AWSIRSA_${replace(title(local.cluster_name), "-", "")}_Velero"

  bucket                      = "velero-${var.platform_name}"
  cluster_name                = var.platform_name
  openid_connect_provider_uri = module.eks.oidc_provider

  values = []

  tags = local.tags
}
