variable "region" {
  description = "The AWS region to deploy the cluster into, e.g. eu-central-1"
  type        = string
}

variable "s3_states_bucket_name" {
  description = "Prefix for S3 bucket name. Since the name should be unique the account number will be added as suffix, e.g. terraform-states-012345678910"
  type        = string
  default     = "terraform-states"
}

variable "table_name" {
  description = "the name of DynamoDb table to store terraform tfstate lock"
  type        = string
  default     = "terraform_locks"
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(any)
  default     = {}
}
