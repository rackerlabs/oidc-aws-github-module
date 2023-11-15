terraform {
  required_providers {
    aws = ">= 5.25.0"
  }
}

output "oidc_arn" {
  value       = aws_iam_role.oidc.arn
  description = "Role ARN for use with AWS Credentials Action"
}
