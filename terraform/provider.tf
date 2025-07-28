terraform {
  # required_version = ">= 1.12" 
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.5.0"
    }
  }
  backend "s3" {
    bucket = "djeukeu-terraform-state"
    key    = "online-learning/terraform.tfstate"
    region = "us-east-2"
    use_lockfile = true
    workspace_key_prefix = "online-learning"
  }
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}
