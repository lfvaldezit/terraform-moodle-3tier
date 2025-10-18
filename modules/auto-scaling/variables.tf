
# --------------- Launch Template  ----------------- #

variable "name" {
    description = "Name for all resources"
    type = string
}

variable "ami_id" {
    description = "AMI ID for the instance"
    type = string
}

variable "instance_type" {
    description = "Instance type for the instance"
    type = string
}

variable "launch_template_secgrp_id" {
    description = "Security group IDs for Launch Template"
    type = set(string)
}

variable "alb_secgrp_id" {
    description = "Security group IDs for ALB"
    type = set(string)
}

variable "create_alb" {
    description = "Whether to create an Application Load Balancer"
    type        = bool
    default     = false
}

# variable "iam_instance_profile" {
#     description = "IAM instance profile for the instance"
#     type = string
# }

variable "user_data" {
    description = "User data for the instance"
    type = string
}

variable "common_tags" {
    description = "Common tags for all resources"
    type = map(string)
}

# --------------- Auto Scaling Group  ----------------- #

variable "min_size" {
    type = number
    default = 1
}

variable "max_size" {
    type = number
    default = 3
}

variable "desired_capacity" {
    type = number
    default = 1
}

# --------------- ALB  ----------------- #

variable "subnets_id" {
    description = "Subnets ID for th ALB"
    type = set(string)
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