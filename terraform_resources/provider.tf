terraform {
  required_version = "~>1.3.0"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~>3.21"
    }
    null = {
      source = "hashicorp/null"
    }
    time = {
      source = "hashicorp/time"
    } 
  }
}

provider "aws" {
  region = "ap-south-1"
}