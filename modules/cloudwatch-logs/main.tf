resource "aws_cloudwatch_log_group" "eks_logs" {
  name              = var.log_group_name
  retention_in_days = var.retention_in_days
  
    tags = {
    Project = "EKS-Observability"
  }
}