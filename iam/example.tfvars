# Template file to use as an example to create terraform.tfvars file. Fill the gaps instead of <...>
# More details on each variable can be found in the variables.tf file

# -- Condition to create or not IAM role for cluster deploy
create_iam_deployer = true

# -- Condition to create or not IAM role for Kaniko deploy
# -- Need in case if used ECR registry. Create it after deploy EKS CLuster
create_iam_kaniko = false

# -- Worker and Deployer role variables

# -- e.g eu-central-1
region = "eu-central-1" # mandatory

deployer_iam_permissions_boundary_policy_arn = "arn:aws:iam::012345678910:policy/eo_role_boundary" # mandatory
kaniko_iam_permissions_boundary_policy_arn   = "arn:aws:iam::012345678910:policy/eo_role_boundary" # mandatory

tags = { # isn't mandatory
  "SysName"     = "EPAM"
  "Environment" = "EKS-TEST-CLUSTER"
  "Project"     = "EDP"
}

# -- Kaniko role variables

cluster_oidc_issuer_url = "https://oidc.eks.eu-central-1.amazonaws.com/id/9876543210"

oidc_provider_arn = "arn:aws:iam::0123456789:oidc-provider/oidc.eks.eu-central-1.amazonaws.com/id/9876543210"

namespace = "kaniko"
