output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "List of public subnet"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of private subnet"
  value       = module.vpc.private_subnets
}
