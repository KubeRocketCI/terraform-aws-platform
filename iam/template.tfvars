# Template file to use as an example to create terraform.tfvars file. Fill the gaps instead of <...>
# More details on each variable can be found in the variables.tf file

# -- Condition to create or not IAM role for cluster deploy
create_iam_deployer = true

# -- Condition to create or not IAM role for Kaniko deploy
# -- Need in case if used ECR registry. Create it after deploy EKS CLuster
create_iam_kaniko = false

# -- Worker and Deployer role variables

# -- e.g eu-central-1
region = "<REGION>" # mandatory

# -- Information about boundary policies
# -- https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html
iam_permissions_boundary_policy_arn = "arn:aws:iam::<AWS_ACCOUNT_ID>:policy/eo_role_boundary" # mandatory

tags = "" # isn't mandatory

# -- Kaniko role variables

cluster_oidc_issuer_url = "https://oidc.eks.<AWS_REGION>.amazonaws.com/id/<AWS_OIDC_OD>"

oidc_provider_arn = "arn:aws:iam::<AWS_ACCOUNT_ID>:oidc-provider/oidc.eks.<AWS_REGION>.amazonaws.com/id/<AWS_OIDC_ID>"

namespace = "<KANIKO_NAMESPACE>"
