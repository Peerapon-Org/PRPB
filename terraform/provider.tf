terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.84.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region  = var.region
  profile = "741448960615_AdministratorAccess"
}

provider "aws" {
  alias   = "virginia"
  region  = "us-east-1"
  profile = "741448960615_AdministratorAccess"
}