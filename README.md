# oidc-aws-github-module

A Terraform module to create an OIDC provider inside an AWS account. This is intended for use with Github Actions, so an S3 bucket can be used for Terraform state.

## Why OIDC?

You won't need stored static AWS repo secrets anymore.

## What is OIDC, and how does this module help me use it?

OIDC is a method of gaining authentication and authorization to a service via JSON Web Tokens (JWT), without storing any secrets at rest. Github has an OIDC identity provider, and it can communicate with any other OIDC provider. Instructions exist for using AWS, Azure, Google Cloud, and Hashicorp Vault. No extra configuration is required in any Github account-level settings. 

Contained herein are terraform resources for creating an OIDC provider in AWS with the express purpose of using an S3 bucket for terraform state storage. S3 access is granted by use of an IAM policy.

Automation came from AWS manual steps for [creating OIDC identity providers](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html#manage-oidc-provider-console) via the console. Github specific configuration of the OIDC IdP comes from docs concerning [adding the identity provider to AWS](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services#adding-the-identity-provider-to-aws)

## Using this module

Configuring and using this module is very straightforward. You just one or more desired repo+branch, and the OIDC role ARN for workflow configuration (below).

```terraform
module "oidc" {
  source = "github.com/rackerlabs/oidc-aws-github-module"
  allowed_repos  = ["repo:some-org/myrepo:*", "repo:another-org/important-repo:specific_branch"]
}

output "oidc_role_arn" {
  value       = module.oidc.role_arn
  description = "Role ARN for use with AWS Credentials Action"
}
```

## Configuring workflows

You'll need the OIDC role ARN configured in your workflow:

```yaml
jobs:
  terraform-plan:
    runs-on: ubuntu-latest
    steps:
      - name: Configure AWS Credentials Action for GitHub Actions
        uses: aws-actions/configure-aws-credentials@v4.0.1
        with:
          aws-region: us-east-2
          # below is the role ARN
          role-to-assume: arn:aws:iam::012345678901:role/githubOIDCAssumeRole
```

The [AWS Credentials Action](https://github.com/marketplace/actions/configure-aws-credentials-action-for-github-actions#overview) is necessary to pass transmit the JWT to AWS and properly disseminate the temporary credentials inside the action. Note the `permissions` section of the workflow; more info can be found [here](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services#adding-permissions-settings).

## Grant greater access using IAM policies

In the event you want to grant further access to this Github OIDC provider, simple create the required `aws_iam_policy` resources, then, with `aws_iam _role_policy_attachment`, attach them to the `module.oidc.name`.