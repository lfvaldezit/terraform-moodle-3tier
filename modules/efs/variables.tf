variable "subnet_id" {
  description = "Set of subnet IDs for mount target"
  type = list(string)
}

variable "name" {
  description = "Base name prefix used to label all created resources "
  type = string
}

variable "security_groups" {
  description = "Security group IDs for EFS"
  type = set(string)
}

variable "common_tags" {
  description = "Common tags for all resources"
  type = map(string)
  default = {}
}