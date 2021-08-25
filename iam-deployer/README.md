iam-deployer
==========

Optional project to create EKS cluster deployer IAM role.

The provided resources will allow to use the following options:

* to use cross-account deployment by assuming created EKSDeployerRole from the root AWS account

The following AWS resources will be created:

* IAM role: `EKSDeployerRole`

How-to-run
----------

1. Fill the input variables with the required values in the `terraform.tfvars` file, refer to the `template.tfvars` as an example. Find the detailed description of the variables in the `variables.tf` file.
2. Apply the changes: `terraform apply`.

Example:
--------

```bash
$ cd terraform-aws-platform-template/iam-deployer
$ terrafrom init
$ terraform apply
```

Note:
-----
Do not forget to attach the created IAM policy to the Principal who is going to deploy the cluster. It can be AWS IAM user group, IAM user or IAM role.

Moreover, it's supposed that the Jenkins instance will assume the provided IAM role to deploy the EKS cluster in a customer account.

As a result:
------------
Put the created IAM role arn to the input variables in the `terraform.tfvars` file to assume it for EKS cluster deployment.

```
role_arn = "arn:aws:iam::<CUSTOMER_AWS_ACCOUNT_ID>:role/EKSDeployerRole"
```
