terraform {
  required_version = "~> 0.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.42.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}

provider "aws" {
  access_key = local.aws_access_key
  secret_key = local.aws_secret_access_key
  region     = local.aws_region
}
