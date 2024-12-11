provider "aws" {
    profile = var.aws_profile
    region = var.aws_region
    default_tags {
        tags = {
            SOURCE = "PLATFORM"
            ENVIRONMENT = "${terraform.workspace}"
            TERRAFORM = "true"
            PROJECT = "INFRA"
            KEY = "PLATFORM"
    }
  }
}

terraform {
  required_version = ">= 0.12"
  backend "s3" {
    profile = "omp-prod"
    bucket = "omp-infratf.tfstate"
    key = "platform"
    workspace_key_prefix = "us-east-2/env"
    region = "us-east-2"
  }
}

terraform {
  required_providers {
    ansible = {
      source = "nbering/ansible"
      version = "1.0.4"
    }
  }
}
provider "ansible" {}