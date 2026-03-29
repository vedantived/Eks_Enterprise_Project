
variable "namespace" {
  default = "logging"
}

variable "service_account_name" {
  default = "fluent-bit"
}
variable "oidc_provider_url" {
  type = string
}
