terraform {
  required_providers {
        cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }

  }
}

resource "cloudflare_record" "this" {
  zone_id = var.zone_id
  name = var.record_name
  type = var.record_type
  content = var.record_content
  proxied = false
}