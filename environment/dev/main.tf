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

data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"   #### To check the our laptop ip dyanamically.. 
}     
# EKS Module 

module "eks" {
  source = "../../modules/eks"

  cluster_name = "eks-zero-trust"

  cluster_role_arn = aws_iam_role.eks_cluster_role.arn

  subnet_ids = concat(
    module.vpc.private_subnet_ids,
    module.vpc.public_subnet_ids
  )

    allowed_cidrs = [
    "${chomp(data.http.my_ip.response_body)}/32"     ### Thhis Line fecth the our laptop ip dyanamically  chomp() cleans API output before using it  
  ]

  cluster_role_policy_attachment = aws_iam_role_policy_attachment.eks_cluster_policy

  tags = {
    Environment = "dev"
    Project     = "EKS-Zero-Trust"
  }
}


##### EKS Cluster role 

resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

############# Enable OIDC Provider (EKS → IAM connection)

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "this" {                  ##Authentication Token - Connecting Terraform to Kubernetes cluster
  name = module.eks.cluster_name
}

data "tls_certificate" "eks" {                                                   ##Fetch TLS Certificate of OIDC URL
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {                                   ##Create OIDC Provider in IAM
  url             = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
}

####### Create IAM Policy (creae s3 bucket) - IAM policy created with permission 

resource "aws_s3_bucket" "irsa_bucket" {
  bucket = "my-irsa-demo-bucket-${random_id.suffix.hex}"

  tags = {
    Name        = "irsa-demo-bucket"
    Environment = "dev"
  }
}

resource "aws_iam_policy" "irsa_s3_policy" {
  name = "irsa-s3-read-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.irsa_bucket.arn
      },

      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.irsa_bucket.arn}/*"
      }
    ]
  })
}}

#### SSM Role for each ec2 standardize and reuse it across all resources

resource "aws_iam_role" "ssm_role" {
  name = "central-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "central-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

#### CREATE NODE IAM ROLE

resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_worker_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_ecr_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ssm_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

#### EKS node Group

resource "aws_eks_node_group" "this" {
  cluster_name    = module.eks.cluster_name
  node_group_name = "eks-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn

  subnet_ids = module.vpc.private_subnet_ids

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.small"]

  capacity_type = "ON_DEMAND"

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_ecr_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_ssm_policy
  ]

  tags = {
    Name        = "eks-node"
    Environment = "dev"
  }
}
