terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      StudentName = var.student_name
      StudentID   = var.student_id
      Project     = "PROG8870-Final"
    }
  }
}
