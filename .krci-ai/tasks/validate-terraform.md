# Task: Validate Terraform Code

## Description

<description>
This task executes a series of validation checks on the Terraform code to ensure quality, security, and adherence to best practices. It runs tools like `terraform validate`, `tflint`, `tfsec`, and others to identify potential issues, then assists in resolving them automatically when possible.
</description>

### Reference Assets

<dependencies>
Dependencies:

- Terraform best practices: [terraform-best-practices.md](./.krci-ai/data/terraform-best-practices.md)
- Repository structure: [repository-structure.md](./.krci-ai/data/repository-structure.md)

CRITICAL: Verify the dependencies exist at the specified paths before proceeding. HALT if any are missing.

## Overview

<overview>
Your task is to validate Terraform code for quality, security, and adherence to best practices. This includes running various validation tools, identifying issues, suggesting fixes, and implementing approved changes to ensure the infrastructure code meets quality standards and follows security best practices.
</overview>

## Prerequisites

<prerequisites>
- Terraform installed (version 1.5.7)
- Required validation tools installed (as specified in validation options)
- Access to repository code
- AWS credentials configured if running against AWS (optional for some validations)

### Required Tools

Depending on the validation options selected, the following tools may be required:

- Terraform CLI
- tflint
- tfsec
- checkov
- terrascan
- terraform-docs (for documentation validation)
</prerequisites>

## Instructions

<instructions>
1. Select the directory to validate (s3-backend, vpc, eks, iam, argo-cd, or all)
2. Choose validation tools to run from the available options
3. Review validation results and recommendations
4. Apply suggested fixes automatically or manually
5. Re-run validation to confirm issues are resolved
</instructions>

## Validation Options

<validation_options>
- terraform validate: Basic syntax and configuration validation
- terraform fmt: Code formatting check
- tflint: Enhanced linting for potential errors and best practices
- tfsec: Security-focused static analysis
- checkov: Policy-as-code security and compliance scanning
- terrascan: Detect compliance and security violations
- infracost: Cost estimation and optimization
- terraform-docs: Documentation completeness check
</validation_options>

## Implementation Steps

### STEP-BY-STEP Implementation

<implementation_steps>
1. CRITICAL FIRST STEP: Ask the user to provide the following information:
   - Which directory to validate? (s3-backend, vpc, eks, iam, argo-cd, or all)
   - Which validation tools to run? (terraform validate, fmt, tflint, tfsec, etc.)
   - Auto-fix preferences? (yes/no/ask)

2. Navigate to the selected directory and prepare for validation:

   ```bash
   cd [selected directory]
   ```

3. Initialize Terraform if needed:

   ```bash
   terraform init
   ```

4. Run selected validation tools in sequence:

   - For Terraform validation:

     ```bash
     terraform validate
     ```

   - For code formatting check:

     ```bash
     terraform fmt -check -recursive
     ```

   - For TFLint:

     ```bash
     tflint
     ```

   - For TFSec:

     ```bash
     tfsec .
     ```

   - For Checkov:

     ```bash
     checkov -d .
     ```

   - For Terrascan:

     ```bash
     terrascan scan -t aws
     ```

   - For cost estimation:

     ```bash
     infracost breakdown --path .
     ```

5. Collect and categorize issues by severity:
   - High: Security vulnerabilities, credential exposure, data loss risks
   - Medium: Non-compliant configurations, performance issues
   - Low: Style issues, documentation gaps, potential improvements

6. Generate automated fixes for common issues:
   - Format issues: Apply terraform fmt
   - Missing tags: Add required tags to resources
   - Insecure defaults: Apply security best practices
   - Common misconfigurations: Apply corrections

7. Present findings to the user:
   - Summarize total issues found by category
   - Present detailed information for each issue
   - Provide reference to relevant best practice
   - Offer automated fixes where applicable

8. Apply fixes based on user preference:
   - If auto-fix is approved, implement changes
   - If manual fixing is preferred, provide guidance
   - Document all changes made in a summary

9. Verify fixes by re-running the validation tools:
   - Run the same tools again
   - Confirm issues are resolved
   - Report on any remaining issues
</implementation_steps>

## Command Reference

<command_reference>

### Terraform Commands

```bash
# Initialize the working directory
terraform init

# Validate the configuration
terraform validate

# Format the code
terraform fmt

# Show execution plan
terraform plan
```

### TFLint Commands

```bash
# Run basic linting
tflint

# Run with AWS plugin
tflint --enable-rule=aws
```

### TFSec Commands

```bash
# Run basic security scan
tfsec .

# Run with custom config
tfsec . --config tfsec.yml
```

### Checkov Commands

```bash
# Run scan on directory
checkov -d .

# Filter by specific check
checkov -d . --check CKV_AWS_*
```

### Terrascan Commands

```bash
# Run scan
terrascan scan

# Run with specific policies
terrascan scan -t aws
```

### Infracost Commands

```bash
# Generate cost estimate
infracost breakdown --path .
```
</command_reference>

## Success Criteria

<success_criteria>
- All selected validation tools executed successfully
- No high-severity security issues remain unaddressed
- Terraform code syntax validated without errors
- Infrastructure code follows AWS and Terraform best practices
- Code formatting follows consistent standards
- Re-validation confirms fixes are effective
</success_criteria>
