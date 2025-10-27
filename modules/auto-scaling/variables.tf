# --------------- Launch Template  ----------------- #

variable "name" {
    description = "Base name prefix used to label all created resources "
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
    description = "Set of subnet IDs where EC2 instances (from ASG) will be deployed"
  type = set(string)
}

# --------------- Auto Scaling Group  ----------------- #

variable "min_size" {
    description = "The minimum number of instances in the Auto Scaling Group"
    type = number
    default = 1
}

variable "max_size" {
    description = "The maximum number of instances in the Auto Scaling Group"
    type = number
    default = 2
}

variable "desired_capacity" {
    description = "The initial number of instances that the Auto Scaling Group should maintain"
    type = number
    default = 1
}

variable "target_group_id" {
    description = "The ARN or ID of the Target Group"
    type = string
}
variable "autoscaling_policy" {
    description = "List of Auto Scaling policies that define how to adjust capacity (scale in/out) based on metrics"
    type = list(object({
      name = string
      scaling_adjustment = number
      cooldown = number

    }))
}

# --------------- Target Group  ----------------- #

variable "vpc_id" {
    description = "The VPC ID where the Target Group and EC2 instances will be created"
  type = string
}

# --------------- CloudWatch Alarm  ----------------- #

variable "cloudwatch_metric_alarm" {
    description = "List of CloudWatch alarms to monitor metrics and trigger Auto Scaling actions"
    type = list(object({
      name = string
      threshold = number
      alarm_description = string 
      comparison_operator = string
    }))
}