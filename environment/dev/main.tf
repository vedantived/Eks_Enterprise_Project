module "vpc" {
  source = "../../modules/vpc"

  project_name             = var.project_name
  vpc_cidr                 = var.vpc_cidr
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs

  common_tags              = var.common_tags
}

module "vpc_flow_logs" {
  source = "../../modules/vpc-flow-logs"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  common_tags  = var.common_tags
}