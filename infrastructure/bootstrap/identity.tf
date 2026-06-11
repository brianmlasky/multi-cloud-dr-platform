# AWS Provider Configuration for the Passive DR Region
provider "aws" {
  region = "us-west-2" 
}

# 1. AWS OIDC Provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  
  # Official GitHub OIDC Thumbprint
  thumbprint_list = ["1b511abead59c6ce207077c0bf0e0043b1382612", "6938fd4d98bab03faadb97b34396831e3780aea1"] 
}

# 2. AWS IAM Role for GitHub Actions (Zero-Trust)
resource "aws_iam_role" "github_actions_dr_role" {
  name = "github-actions-dr-deployer"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
          StringLike = {
            # Strictly limit access to THIS specific repository
            "token.actions.githubusercontent.com:sub": "repo:brianmlasky/multi-cloud-dr-platform:*"
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# 3. Attach permissions to the role (Administrator for infrastructure provisioning)
resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions_dr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
