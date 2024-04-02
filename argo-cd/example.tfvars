#---------------------------------------------#
# ArgoCD Master Deployment
#---------------------------------------------#
# we are running Argo CD Master instance, which deploys workload in different EKS clusters
# the below option enables IRSA for Argo CD pods and defines the list of IAM roles for the remote EKS clusters admins
argocd_master_enabled = true
argocd_master_role_name_list = [
  "arn:aws:iam::012345678910:role/EDPArgoCDClusterAdmin", # AWS IAM Role from the remote EKS cluster
]
oidc_provider_arn = "arn:aws:iam::012345678910:oidc-provider/oidc.eks.eu-central-1.amazonaws.com/id/9876543210"

#---------------------------------------------#
# ArgoCD Agent Deployment
#---------------------------------------------#
# 'Argo CD Agent' AWS IAM Role provides access to the EKS cluster.
# The 'Argo CD Master' AWS IAM Role is allowed to assume the this role to deploy workloads in the EKS cluster
argocd_agent_enabled                = false
argocd_agent_argocd_master_role_arn = "arn:aws:iam::012345678910:role/AWSIRSA_Shared_ArgoCDMaster"

#---------------------------------------------#
# Common variables
#---------------------------------------------#
platform_name                 = "shared"
region                        = "eu-central-1"
role_arn                      = "arn:aws:iam::012345678910:role/EKSDeployerRole"
role_permissions_boundary_arn = "arn:aws:iam::012345678910:policy/eo_role_boundary"
tags = {
  "Environment" = "EKS-TEST-CLUSTER"
  "Project"     = "TEST"
  "user:tag"    = "eks-test"
}
