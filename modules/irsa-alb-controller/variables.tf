variable "oidc_provider_arn" {}
variable "oidc_provider_url" {}

variable "namespace" {
  default = "kube-system"
}

variable "service_account_name" {
  default = "aws-load-balancer-controller"
}