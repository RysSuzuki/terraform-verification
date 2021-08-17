provider "aws" {
  region  = "us-east-1"
  profile = var.aws_profile
}

terraform {
  required_version = ">= 1.0.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}