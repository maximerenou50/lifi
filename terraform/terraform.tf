terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.6.2"

  backend "s3" {
    bucket = "lifi-mrenou"
    key    = "terraform"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = "eu-central-1"
}
