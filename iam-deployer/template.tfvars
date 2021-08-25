# Template file to use as an example to create terraform.tfvars file. Fill the gaps instead of <...>
# More details on each variable can be found in the variables.tf file

aws_profile = "<AWS_PROFILE>" # define if not default

region = "<REGION>" # mandatory

role_arn = "<ROLE_ARN" # role to assume to run terraform apply, isn't mandatory

aws_root_account_id = "<AWS_ROOT_ACCOUNT_ID>" # mandatory

tags = "<TAGS>" # isn't mandatory
