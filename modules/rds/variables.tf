variable "name" {
  type = string
}

variable "engine" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "db_instance_type" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_pass" {
  type = string
  sensitive = true
}

variable "subnet_id" {
  type = set(string)
}

variable "vpc_security_group_ids" {
  type = set(string)
}

variable "common_tags" {
  type = map(string)
}