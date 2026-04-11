output "fluentbit_role_arn" {
  value = module.irsa_fluentbit.fluentbit_role_arn
}
output "oidc_provider_debug" {
  value = local.oidc_provider
}
