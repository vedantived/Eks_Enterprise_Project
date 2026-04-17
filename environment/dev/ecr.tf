resource "aws_ecr_repository" "app_repo" {
  name = "eks-zero-trust-app"

  image_scanning_configuration {
    scan_on_push = true             ##Every time an image is pushed AWS automatically scans it
  }

  image_tag_mutability = "MUTABLE"    ##Allows you to overwrite existing image tags
}
