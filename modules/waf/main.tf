resource "aws_wafv2_web_acl" "this" {
  name  = "eks-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "SQLiRule"
    priority = 1

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"   #  CORRECT NAME
        vendor_name = "AWS"
      }
    }

    override_action {
      none {}   #  keep this for managed rules
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLiRule"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "eks-waf"
    sampled_requests_enabled   = true
  }
}
resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}