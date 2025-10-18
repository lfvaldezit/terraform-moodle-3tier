provider "aws" {
  region  = local.aws_region
  profile = local.profile
}

provider "cloudflare" {
  api_token = var.api_token
}
