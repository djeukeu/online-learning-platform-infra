terraform {
  required_version = ">= 1.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    # helm = {
    #   source  = "hashicorp/helm"
    #   version = "3.0.2"
    # }
  }

  backend "s3" {
    bucket = "djeukeu-terraform-state"
    # key          = "online-learning/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      project     = var.app_name
      managedBy   = "Terraform"
      environment = var.environment
    }
  }
}

# provider "helm" {
#   kubernetes = {
#     host                   = aws_eks_cluster.eks_cluster.endpoint
#     cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
#     exec = {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.eks_cluster.name]
#       command     = "aws"
#     }
#   }
# }
