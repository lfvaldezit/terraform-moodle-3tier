# --------------- VPC ----------------- #

variable "name" {
  description = "Name for all resources"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnets"
  type = list(object({
    name       = string
    cidr_block = string
    az         = string
  }))
}

variable "app_subnets" {
  description = "List of app subnets"
  type = list(object({
    name       = string
    cidr_block = string
    az         = string
  }))
}

variable "data_subnets" {
  description = "List of db subnets"
  type = list(object({
    name       = string
    cidr_block = string
    az         = string
  }))
}

# --------------- EC2 ----------------- #

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

# --------------- RDS ----------------- #


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
  type      = string
  sensitive = true
}

# --------------- ELASTICACHE ----------------- #

variable "node_type" {
  type = string
}

# --------------- ASG ----------------- #

variable "ami_id_ASG" {
  type = string
}

variable "health_check_path" {
  type = string
}

variable "redis_dns_name" {
  type    = string
  default = "value"
}
#--------------- CloudFlare --------------- #

variable "api_token" {
  description = "Generated API Token to access services and resources "
  type        = string
}

variable "zone_id" {
  type = string
}

variable "validation_method" {
  type    = string
  default = "DNS"
}

variable "create_route53_records" {
  type    = bool
  default = false
}

variable "domain_name" {
  type = string
}

variable "record_name" {
  type = string
}