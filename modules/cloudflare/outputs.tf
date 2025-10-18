output "hostname" {
    description = "The FQDN of the record"
  value = cloudflare_record.this.hostname
}