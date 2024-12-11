provider "aws" {
    region = var.aws_region
    default_tags {
        tags = {
            SOURCE = "PLATFORM"
            TERRAFORM = "true"
            PROJECT = "INFRA"
            KEY = "PLATFORM"
    }
  }
}

terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket = "cup-terraform-test.tfstate"
    key = "platform"
    workspace_key_prefix = "us-east-1/env"
    region = "us-east-1"
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