variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "security_group_ids" {
  type = set(string)
}

variable "ec2_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "user_data" {
  type = string
  default = "null"
}

variable "common_tags" {
  type = map(string)
  default = {}
}