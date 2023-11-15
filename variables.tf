variable oidc_iam_role_name {
  type        = string
  default     = "githubOIDCAssumeRole"
  description = "name of OIDC IAM assume-role"
}

variable oidc_iam_policy_name {
  type        = string
  default     = "OIDCAccessPolicy"
  description = "name of IAM policy for accessing OIDC"
}

variable s3_iam_policy_name {
  type        = string
  default     = "s3TerraformStateBucketPolicy"
  description = "name of IAM policy for accessing S3"
}

variable allowed_repos {
  type        = list
  #default    = ["repo:RSS-Engineering/undercloud:*", "repo:cringdahl/terraform-actions:*"]
  description = "one or more allowed repos with required branches, wildcards allowed"
}
