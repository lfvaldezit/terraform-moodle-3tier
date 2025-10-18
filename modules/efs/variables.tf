variable "subnet_id" {
  type = list(string)
}

variable "name" {
  type = string
}

variable "security_groups" {
  type = set(string)
}

variable "common_tags" {
  type = map(string)
  default = {}
}