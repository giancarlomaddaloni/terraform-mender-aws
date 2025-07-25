terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.95.0, < 6.0.0"
    }
  }

  backend "s3" {
    bucket         = "mender-states"
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
 