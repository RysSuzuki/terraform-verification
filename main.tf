provider "aws" {
  region  = "ap-northeast-1"
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

  # 先にs3バケットを作っておく必要がある
  backend "s3" {
    # 適当なバケット
    bucket  = ver.tfstate_backet
    key     = "terraform.tfstate.aws"
    region  = "ap-northeast-1"
    profile = var.aws_profile
  }
}
