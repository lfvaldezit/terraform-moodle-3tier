output "RDS-ENDPOINT" {
  value = module.rds.rds_dns_name
}

output "REDIS-ENDPOINT" {
  value = module.redis-cache.primary_endpoint_address
}