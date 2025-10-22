# --------------- AMI  ----------------- #

variable "source_instance_id" {
    type = string
}

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

variable "user_data" {
    description = "User data for the instance"
    type = string
}

variable "common_tags" {
    description = "Common tags for all resources"
    type = map(string)
}

variable "subnets_id" {
  type = set(string)
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

variable "target_group_id" {
    type = string
}

# --------------- Target Group  ----------------- #

variable "vpc_id" {
  type = string
}

