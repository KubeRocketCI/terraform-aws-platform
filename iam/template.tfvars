# -- e.g eu-central-1
region = "eu-central-1"

# At KubeRocketCI we can create roles only with boundary
iam_permissions_boundary_policy_arn = "arn:aws:iam::012345678910:policy/role_boundary"

tags = {
  "SysName"     = "KubeRocketCI"
  "Environment" = "core"
  "Project"     = "my-proj"
  "ManagedBy"   = "terraform"
}

# -- Trust policy of the deployer role (optional) ------------------------------
# By default the whole account and the EC2 service may assume the role; see iam/variables.tf.
# The listed roles must exist: add the Atlantis role after the eks project has created it.
# deployer_role_trust_account          = false
# deployer_role_trust_ec2              = false
# deployer_role_trusted_principal_arns = ["arn:aws:iam::012345678910:role/<ADMINISTRATOR_ROLE>"]
