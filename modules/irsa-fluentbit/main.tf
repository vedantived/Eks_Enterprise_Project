data "aws_caller_identity" "current" {}

resource "aws_iam_role" "fluentbit_role" {
  name = "fluentbit-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(var.oidc_provider_url, "https://", "")}"
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
          }
        }
      }
    ]
  })
}

# IAM POLICY (CloudWatch Logs)

resource "aws_iam_policy" "fluentbit_policy" {
  name = "FluentBitCloudWatchPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach policy to role

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.fluentbit_role.name
  policy_arn = aws_iam_policy.fluentbit_policy.arn
}