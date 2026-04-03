resource "aws_sns_topic" "alerts" {
  name = "eks-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.email
}

resource "aws_cloudwatch_log_metric_filter" "error_filter" {
  name           = "error-count"
  log_group_name = var.log_group_name
  pattern = "FINAL ALERT TEST"  

  metric_transformation {
    name      = "ErrorCount"
    namespace = "EKSLogs"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "error_alarm" {
  alarm_name          = "eks-error-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1

  metric_name = "ErrorCount"
  namespace   = "EKSLogs"

  period    = 60
  statistic = "Sum"
  threshold = 0

  alarm_actions = [aws_sns_topic.alerts.arn]
}