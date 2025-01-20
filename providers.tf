######################################################################
# Provaider AWS
######################################################################
provider "aws" {
  alias   = "pra_idp_dev"
  region  = var.aws_region
  profile = var.profile

  default_tags {
    tags = var.common_tags
  }
}

######################################################################
# Definicion de versiones - Terraform - Provaiders
######################################################################
terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.31.0"
    }
  }
    backend "s3" {
        bucket         = "pragma-fc-dev-s3-tf-state"
        key            = "pragma-fc-dev-workload/terraform.tfstate"
        region         = "us-east-1"
        dynamodb_table = "pragma-fc-dev-dyntbl-workload-tflocks"
        profile        = "pra_idp_dev"
    }
}
