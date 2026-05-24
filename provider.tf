terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.46.0" # Specify the desired version of the AWS provider.
    }
  }
}
provider "aws" {
  region = "ap-south-1" # Replace with your desired AWS region.
}