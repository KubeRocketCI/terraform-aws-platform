region               = "<REGION>"
platform_name        = "<PLATFORM_NAME>"
platform_domain_name = "<PLATFORM_DNS>"

role_arn                      = "arn:aws:iam::<AWS_ACCOUNT_ID>:role/KRCIDeployerRole"
role_permissions_boundary_arn = "arn:aws:iam::<AWS_ACCOUNT_ID>:policy/eo_role_boundary"

create_kaniko_iam_role   = false # Create IAM role for Kaniko
create_atlantis_iam_role = false # Create IAM role for Atlantis

create_cd_pipeline_operator_irsa = false # Create IRSA for CD Pipeline Operator
create_argocd_irsa               = false # Create IRSA for Argo CD

cd_pipeline_operator_agent_role_arn = "arn:aws:iam::<AWS_ACCOUNT_B_ID>:role/AWSIRSA_<ClusterName>_CDPipelineAgent"
argocd_agent_role_arn               = "arn:aws:iam::<AWS_ACCOUNT_B_ID>:role/AWSIRSA_<ClusterName>_ArgoCDAgentAccess"
# cd_pipeline_operator_irsa_role_arn  = "arn:aws:iam::<AWS_ACCOUNT_A_ID>:role/AWSIRSA_<ClusterName>_CDPipelineOperator"
# argocd_irsa_role_arn                = "arn:aws:iam::<AWS_ACCOUNT_A_ID>:role/AWSIRSA_<ClusterName>_ArgoCDMaster"

vpc_id             = "<VPC_ID>" # VPC ID
private_subnets_id = []         # EKS must have two subnets.
public_subnets_id  = []         # ALB must have two subnets.

infra_public_security_group_ids = [] # List with security groups

# -- Parameter in AWS Parameter Store that contain data in format "account:token" in base64 format
add_userdata = <<-EOF
#!/bin/bash
export TOKEN=$(aws ssm get-parameter --name <PARAMETER_NAME> --query 'Parameter.Value' --region <REGION> --output text)
cat <<DATA > /var/lib/kubelet/config.json
{
  "auths":{
    "https://index.docker.io/v1/":{
      "auth":"$TOKEN"
    }
  }
}
DATA
EOF

spot_instance_types = [] # list with instance types

tags = ""

# OIDC Identity provider
cluster_identity_providers = {}

# -- nginx-ingress -> Envoy Gateway migration (optional, default off) ----------
# Two related switches for a zero-downtime cutover; see eks/variables.tf.
# Step 1 - provision the Envoy Gateway data-plane target group (no traffic yet):
# envoy_gateway_enabled = true
# Step 2 - once that target group is healthy, flip the ALB default action to Envoy:
# platform_default_gateway = "envoy"

# -- Scope of the IAM roles for ServiceAccounts (optional) ---------------------
# By default every ServiceAccount of the cluster can assume the External Secrets Operator and Kaniko roles; see eks/variables.tf.
# Every SecretStore that authenticates through the External Secrets Operator role needs its ServiceAccount listed or matched:
# the platform chart uses externalsecrets-aws, the add-ons that sync secrets bring their own.
# external_secrets_service_accounts     = ["<PLATFORM_NAMESPACE>:externalsecrets-aws"]
# external_secrets_secrets_manager_arns = ["arn:aws:secretsmanager:<REGION>:<AWS_ACCOUNT_ID>:secret:/edp/*"]
# external_secrets_kms_key_arns         = [] # customer managed KMS keys that encrypt the parameters and secrets
# kaniko_service_accounts               = ["<PLATFORM_NAMESPACE>:tekton"]
# kaniko_repository_actions             = ["ecr:BatchCheckLayerAvailability", "ecr:BatchGetImage", "ecr:CompleteLayerUpload", "ecr:GetDownloadUrlForLayer", "ecr:InitiateLayerUpload", "ecr:PutImage", "ecr:UploadLayerPart"]
