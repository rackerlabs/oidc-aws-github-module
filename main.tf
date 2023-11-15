# The actual OIDC provider
# Thumbprint arbitrary, GH OIDC connector doesn't actually require thumbprint
resource "aws_iam_openid_connect_provider" "default" {
  client_id_list  = ["sts.amazonaws.com"]
  url             = "https://token.actions.githubusercontent.com"
  thumbprint_list = ["ffffffffffffffffffffffffffffffffffffffff"] # github specific
}

# assume-role for OIDC GitHub integration
# this role's ARN must be passed to the AWS OIDC Action
# Will need S3 permissions as well
resource "aws_iam_role" "oidc" {
  name                 = var.oidc_iam_role_name
  assume_role_policy   = data.aws_iam_policy_document.oidc.json
  description          = "For use with OIDC Github integration"
  max_session_duration = 3600
}

# OIDC assume-role policy
data "aws_iam_policy_document" "oidc" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"] # value required by official AWS OIDC Action
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = var.allowed_repos
    }

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.default.arn]
    }
  }
}

# service policies
resource "aws_iam_policy" "s3" {
  description = "Minimal required permissions to use Terraform state files"
  name        = var.s3_iam_policy_name
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "s3:PutObject",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:DeleteObject"
          ]
          Effect   = "Allow"
          Resource = "*"
          Sid      = "VisualEditor0"
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_policy" "oidc" {
  description = "Minimal required permissions for OIDC policy"
  name        = var.oidc_iam_policy_name
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "iam:GetRole",
            "iam:GetPolicy",
            "iam:GetOpenIDConnectProvider",
            "iam:GetPolicyVersion",
            "iam:ListRolePolicies",
            "iam:ListAttachedRolePolicies"
          ]
          Effect   = "Allow"
          Resource = "*"
          Sid      = "VisualEditor0"
        },
      ]
      Version = "2012-10-17"
    }
  )
}

# service policy attachments
resource "aws_iam_role_policy_attachment" "oidc-policy-attach" {
  role       = aws_iam_role.oidc.name
  policy_arn = aws_iam_policy.oidc.arn
}

resource "aws_iam_role_policy_attachment" "s3-policy-attach" {
  role       = aws_iam_role.oidc.name
  policy_arn = aws_iam_policy.s3.arn
}

