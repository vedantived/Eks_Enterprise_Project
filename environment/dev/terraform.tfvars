project_name = "Eks_Enterprise"
aws_region   = "ap-south-1"
app_port     = 3000


vpc_cidr = "12.0.0.0/16"

public_subnet_cidrs = [
  "12.0.1.0/24",
  "12.0.2.0/24"
]
private_app_subnet_cidrs = [
  "12.0.3.0/24",
  "12.0.4.0/24"
]

instance_type    = "t3.micro"
desired_capacity = 2
min_size         = 2
max_size         = 4

common_tags = {
  Environment = "dev"
  Project     = "EKS-Zero-Trust"
}
service_account_name = "irsa-sa"