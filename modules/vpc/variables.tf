variable "name" {
  description = "Name for all resources"
  type = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type = map(string)
}

variable "public_subnets" {
  description = "List of public subnets"
  type = list(object({
    name                  = string
    cidr_block            = string
    az                    = string
  }))
}

variable "app_subnets" {
  description = "List of app subnets"
  type = list(object({
    name                  = string
    cidr_block            = string
    az                    = string
  }))
}

variable "data_subnets" {
  description = "List of db subnets"
  type = list(object({
    name                  = string
    cidr_block            = string
    az                    = string
  }))
}

variable "region" {
  type = string
}

variable "endpoint_security_group_ids" {
  type = set(string)
}