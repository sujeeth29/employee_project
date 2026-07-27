terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    helm = {
      source = "hashicorp/helm",
      version = "~> 2.12"
    }
    kubernetes = {
      source = "hashicorp/kubernetes",
      version = "~> 2.25"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
