# Template file to use as an example to create terraform.tfvars file. Fill the gaps instead of <...>

region = "eu-central-1" # mandatory

tags = { # isn't mandatory
  "SysName"     = "EPAM"
  "Environment" = "EKS-TEST-CLUSTER"
  "Project"     = "EDP"
}
