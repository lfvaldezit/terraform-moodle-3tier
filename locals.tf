locals {
  aws_region = "us-east-1"
  profile    = "default"

  common_tags = {
    Owner       = "user"
    Environment = "test"
    ManagedBy   = "Terraform"
  }
}