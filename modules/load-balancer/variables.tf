variable "name" {
    description = "Name for all resources"
    type = string
}

variable "common_tags" {
    description = "Common tags for all resources"
    type = map(string)
}

# --------------- Target Group  ----------------- #

variable "vpc_id" {
  description = "The VPC ID where the load balancer will be created"
  type = string
}

variable "health_check_path" {
  description = "Health Check configuration"
  type = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener"
  type        = string
}

# --------------- ALB  ----------------- #

variable "alb_secgrp_id" {
    description = "Security group IDs for ALB"
    type = set(string)
}


variable "subnets_id" {
    description = "Subnets ID for th ALB"
    type = set(string)
}

# --------------- Listnere Rules  ----------------- #

variable "listener_rule" {
  description = "List of listener Rules"
  type = list(object({
    path_pattern = list(string)
    type = string
    status_code = number
    content_type = string
    message_body = string
  }))
}