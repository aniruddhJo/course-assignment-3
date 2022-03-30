terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.8.0"
    }
  }
  backend "s3" {
    bucket = "terraformassignment"
    key    = "state/terraform.state"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}