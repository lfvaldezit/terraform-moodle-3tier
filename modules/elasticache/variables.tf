variable "name" {
    type = string
}

variable "node_type" {
  type = string
}

variable "security_group_ids" {
  type = set(string)
}

variable "subnet_ids" {
  type = set(string)
}

variable "common_tags" {
  type = map(string)
}