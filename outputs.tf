output "role_arn" {
  value       = aws_iam_role.oidc.arn
  description = "Role ARN for use with AWS Credentials Action"
}

output "role_name" {
  value       = aws_iam_role.oidc.name
  description = "Role name, for use with policies attached outside this module"
}