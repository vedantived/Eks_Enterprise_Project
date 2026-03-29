variable "log_group_name" {
  default = "/eks/fluentbit-logs"
}

variable "retention_in_days" {
  default = 7     ### Logs automatically deleted after 7 days 
}
