# terraform-security-ci-pipeline
CI/CD pipeline for Terraform security: integrates tfsec, Checkov, and custom OPA/Rego policies to enforce AWS CloudTrail guardrails (multi-region, KMS, log file validation) and automatically fail builds on violations.
