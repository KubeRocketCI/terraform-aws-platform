# -- e.g eu-central-1
region = "eu-central-1"

# At EPAM we can create roles only with boundary
iam_permissions_boundary_policy_arn = "arn:aws:iam::012345678910:policy/role_boundary"

tags = {
  "SysName"     = "KubeRocketCI"
  "Environment" = "core"
  "Project"     = "my-proj"
  "ManagedBy"   = "terraform"
}
