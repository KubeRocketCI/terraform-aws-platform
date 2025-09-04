# Terraform Best Practices

This document outlines the best practices to follow when working with Terraform code in this repository.

## Code Structure and Organization

- **Use Modules**: Leverage modules for reusable infrastructure components
- **Directory Structure**: Follow the established directory structure for consistency
- **File Naming**: Use descriptive names for .tf files based on their function (e.g., `main.tf`, `variables.tf`, `outputs.tf`)
- **Resource Naming**: Use consistent naming conventions for resources (e.g., `aws_resource_name`)

## Terraform Configuration

- **Version Pinning**: Always specify the required Terraform version in `versions.tf`
- **Provider Versions**: Pin AWS provider versions to avoid unexpected changes
- **Backend Configuration**: Use the S3 backend with state locking via `DynamoDB`
- **Variable Declarations**: Include type constraints, descriptions, and default values where appropriate
- **Output Declarations**: Include descriptions and make outputs consistent across modules

## Security Practices

- **IAM Least Privilege**: Follow the principle of the least privilege for IAM roles
- **No Hardcoded Secrets**: Never commit secrets to version control
- **Use KMS Encryption**: Encrypt sensitive data in S3 state files

## Development Workflow

- **Format Code**: Run `terraform fmt` before committing changes
- **Validate Code**: Use `terraform validate` to check for errors
- **Use Linters**: Apply `tflint` to check for potential issues
- **Security Scanning**: Run `tfsec` to identify security concerns
- **Document Changes**: Update README.md and other documentation when making significant changes

## State Management

- **Remote State**: Always use the S3 backend for state storage
- **State Locking**: Enable DynamoDB locking to prevent concurrent modifications
- **Workspace Isolation**: Use workspaces for environment isolation only when necessary
- **State Import**: Document any manual state imports

## Resource Management

- **Tagging Strategy**: Apply consistent tags to all resources for identification, cost allocation, and operations
- **Resource Dependencies**: Use explicit dependencies where Terraform cannot infer them

## Cost Optimization

- **Resource Sizing**: Right-size instances and other resources
- **Spot Instances**: Use spot instances for non-critical workloads
- **Autoscaling**: Implement autoscaling for dynamic workloads
- **Scheduled Scaling**: Use scheduled scaling for predictable workload patterns

## Testing and Validation

- **Plan Review**: Always review `terraform plan` output before applying changes
- **Automated Testing**: Implement automated testing where possible

## AWS EKS Specific Practices

- **Node Group Configuration**: Use mixed instance policies for cost optimization
- **Cluster Autoscaler**: Configure proper resource requests/limits
- **IAM Roles for Service Accounts (IRSA)**: Use IRSA instead of instance profiles
- **Add-On Management**: Manage add-ons consistently through Terraform or Helm
- **Control Plane Logging**: Enable EKS control plane logging
- **Subnet Tagging**: Properly tag subnets for AWS load balancer integration

## Continuous Integration

- **CI Pipelines**: Set up CI pipelines for automated validation (e.g., KubeRocketCI)
- **PR Validation**: Run `terraform plan` on pull requests
- **Atlantis Integration**: Use Atlantis for collaborative Terraform workflows
- **Security Scanning**: Include security scanning in CI process
- **Documentation Updates**: Verify documentation is updated with code changes

## Upgrade Process

- **Version Testing**: Test terraform version upgrades in isolation
- **Provider Updates**: Test AWS provider updates carefully
- **Module Updates**: Review module updates for breaking changes
- **Deprecation Handling**: Address deprecation warnings promptly
