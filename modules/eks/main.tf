resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids = var.subnet_ids

    endpoint_private_access = true
    endpoint_public_access  = true

    public_access_cidrs = var.allowed_cidrs
  }

  depends_on = [
    var.cluster_role_policy_attachment
  ]

  tags = var.tags
}