resource "aws_elasticache_cluster" "this" {
  cluster_id           = var.name
  engine               = "redis"
  node_type            = var.node_type
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  security_group_ids = var.security_group_ids
  subnet_group_name = aws_elasticache_subnet_group.this.name
  tags = merge({Name = var.name}, var.common_tags)
}

resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.name}-sn-grp"
  subnet_ids = var.subnet_ids                                                                  
}

# resource "aws_elasticache_replication_group" "this" {
#   replication_group_id          = var.name
#   description = "Redis"
#   node_type                     = var.node_type
#   num_cache_clusters = 2
#   parameter_group_name          = "default.redis7"
#   port                          = 6379
#   automatic_failover_enabled    = true
#   multi_az_enabled              = true
#   subnet_group_name             = aws_elasticache_subnet_group.this.name
#   security_group_ids            = var.security_group_ids
#   engine_version                = "7.0"
#   apply_immediately             = true
#   at_rest_encryption_enabled    = false
#   transit_encryption_enabled    = false
#    tags = merge({Name = var.name}, var.common_tags)
# }