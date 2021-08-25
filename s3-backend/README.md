s3-backend
==========

Optional project to create initial resources to start using Terraform from the scratch.

The provided resources will allow to use the following Terraform options:

* to store Terraform states remotely in the Amazon S3 bucket;
* to manage remote state access with S3 bucket policy;
* to support state locking and consistency checking via DynamoDB.

The following AWS resources will be created:

* S3 bucket: `terraform-states-<AWS_ACCOUNT_ID>`
* S3 bucket policy: `terraform-states-<AWS_ACCOUNT_ID>`
* DynamoDB lock table: `terraform_locks`

How-to-run
----------

1. Fill the input variables with the required values in the `terraform.tfvars` file, refer to the `template.tfvars` as an example. Find the detailed description of the variables in the `variables.tf` file.
2. Apply the changes: `terraform apply`.

Example:
--------

```bash
$ cd terraform-aws-platform-template/s3-backend
$ terrafrom init
$ terraform apply
```

How-to use results for the Terraform projects
---------------------------------------------

As a result, the projects that run Terraform can use the following definition for remote state configuration:

```bash
terraform {
  backend "s3" {
    bucket         = "terraform-states-<AWS_ACCOUNT_ID>"
    key            = "<PROJECT_NAME>/<REGION>/terraform/terraform.tfstate"
    region         = "<REGION>"
    acl            = "bucket-owner-full-control"
    dynamodb_table = "terraform_locks"
    encrypt        = true
  }
}
```

where:
  - `AWS_ACCOUNT_ID` is AWS account id, e.g. `012345678910`,
  - `REGION` is AWS region, e.g. `eu-central-1`,
  - `PROJECT_NAME` is your project name, eg. `demo-eks`.

Example:
--------

```bash
terraform {
  backend "s3" {
    bucket         = "terraform-states-012345678910"
    key            = "demo-eks/eu-central-1/terraform/terraform.tfstate"
    region         = "eu-central-1"
    acl            = "bucket-owner-full-control"
    dynamodb_table = "terraform_locks"
    encrypt        = true
  }
}
```
