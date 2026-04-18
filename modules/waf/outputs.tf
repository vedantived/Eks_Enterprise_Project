output "waf_arn" {
  description = "WAF Web ACL ARN"
  value       = aws_wafv2_web_acl.this.arn
}

output "waf_name" {
  description = "WAF Web ACL Name"
  value       = aws_wafv2_web_acl.this.name
}