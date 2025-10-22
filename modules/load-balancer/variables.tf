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
  type = string
}

variable "health_check_path" {
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
