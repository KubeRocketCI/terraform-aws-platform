# -- e.g eu-central-1
region = "eu-central-1"

# At KubeRocketCI we can create roles only with boundary
iam_permissions_boundary_policy_arn = "arn:aws:iam::012345678910:policy/role_boundary"

# OpenID Connect provider URL used for creating Atlantis IAM role
oidc_provider = "oidc.eks.<REGION>.amazonaws.com/id/<AWS_OIDC_ID>"

tags = {
  "SysName"     = "KubeRocketCI"
  "Environment" = "core"
  "Project"     = "my-proj"
  "ManagedBy"   = "terraform"
}
