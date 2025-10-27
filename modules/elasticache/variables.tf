variable "name" {
  description = "Base name prefix used to label all created resources "
    type = string
}

variable "node_type" {
  description = "Instance class to be used"
  type = string
}

variable "security_group_ids" {
  description = "Security group IDs for Elasticache"
  type = set(string)
}

variable "subnet_ids" {
  description = "Set of VPC Subnet IDs for the cache subnet group"
  type = set(string)
}

variable "common_tags" {
  description = "Common tags for all resources"
  type = map(string)
}