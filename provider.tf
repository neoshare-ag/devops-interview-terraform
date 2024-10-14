terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = local.default_region
}

locals {
  default_region = "eu-central-1"
  default_tags = {
    Terraform  = true
    Department = "DevOps"
    Project    = "devops/project"
  }
}
