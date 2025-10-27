variable "name" {
  type        = string
}

# --------------- VPC ----------------- #

variable "cidr_block" {
  type        = string
}

variable "public_subnets" {
  type = list(object({
    name       = string
    cidr_block = string
    az         = string
  }))
}

variable "app_subnets" {
  type = list(object({
    name       = string
    cidr_block = string
    az         = string
  }))
}

variable "data_subnets" {
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

variable "min_size" {
  type = string
}

variable "max_size" {
  type = string
}

variable "desired_capacity" {
  type = string
}

variable "autoscaling_policy" {
  type = list(object({
    name               = string
    scaling_adjustment = number
    cooldown           = number

  }))
}

variable "cloudwatch_metric_alarm" {
  type = list(object({
    name              = string
    threshold         = number
    alarm_description = string
    comparison_operator = string
  }))
}

variable "listener_rule" {
  type = list(object({
    path_pattern = list(string)
    type = string
    status_code = number
    content_type = string
    message_body = string
  }))
}
#--------------- CloudFlare --------------- #

variable "api_token" {
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

#--------------- Moodle --------------- #

variable "admin_user" {
  type = string
}

variable "admin_pass" {
  type = string
}

variable "admin_email" {
  type = string
}