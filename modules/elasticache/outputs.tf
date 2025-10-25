output "cache_nodes" {
  value = aws_elasticache_cluster.this.cache_nodes
}

# output "primary_endpoint_address" {
#   value = aws_elasticache_replication_group.this.primary_endpoint_address
# }