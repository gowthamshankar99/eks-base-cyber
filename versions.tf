terraform {
  required_version = "~> 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.22"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }

  # backend "remote" {
  #  hostname     = "app.terraform.io"
  #  organization = "aws-engineering-poc"
  #  workspaces {
  #    prefix = "poc-platform-eks-base-"
  #  }
  # }
}

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn     = "arn:aws:iam::${var.aws_account_id}:role/${var.aws_assume_role}"
    session_name = "poc-platform-eks-base-cyber"
  }

  default_tags {
    tags = {
      pipeline = "poc-platform-eks-base-cyber"
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", var.instance_name, "--region", var.aws_region, "--role-arn", "arn:aws:iam::${var.aws_account_id}:role/${var.aws_assume_role}"]
  }
}
