provider "aws" {
  region = "us-east-2"  # Change to your AWS region
}

# 🔹 Create VPC for EKS
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "eks-vpc"
  cidr   = "10.0.0.0/16"
  azs    = ["us-east-2a", "us-east-2b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
  enable_nat_gateway = true
}

# 🔹 Create IAM Role for EKS
resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = ["eks.amazonaws.com", "ec2.amazonaws.com"]
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ec2_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


# 🔹 Create EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     = "self-healing-eks"
  role_arn = aws_iam_role.eks_role.arn
  vpc_config {
    subnet_ids = module.vpc.public_subnets
  }
}

# 🔹 Create Node Group (Auto Scaling)
resource "aws_eks_node_group" "self_healing_nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "self-healing-node-group"
  node_role_arn   = aws_iam_role.eks_role.arn
  subnet_ids      = module.vpc.private_subnets
  instance_types  = ["t3.micro"]
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
}