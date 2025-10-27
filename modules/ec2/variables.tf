variable "ami_id" {
  description = "AMI ID for the instance"
  type = string
}

variable "instance_type" {
  description = "Instance type for the instance"
  type = string
}

variable "security_group_ids" {
  description = "Security Group ID for the instance"
  type = set(string)
}

variable "name" {
  description = "Base name prefix used to label all created resources "
  type = string
}

variable "subnet_id" {
  description = "subnet IDs where EC2 instance will be deployed"
  type = string
}

variable "user_data" {
  description = "User data script for the instance"
  type = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type = map(string)
}