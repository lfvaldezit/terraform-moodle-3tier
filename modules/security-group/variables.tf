variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ingress_cidr_from_port" {
  type        = list(number)
  description = "List of starting ports for cidr ingress rules of the EC2 security group."
  default = [ 0 ]
}

variable "ingress_cidr_to_port" {
  type        = list(number)
  description = "List of ending ports for cidr ingress rules of the EC2 security group."
  default = [ 0 ]
}

variable "ingress_cidr_protocol" {
  type        = list(string)
  description = "List of protocols for cidr ingress rules of the EC2 security group."
  default = [ 0 ]
}

variable "ingress_cidr_block" {
  type        = list(string)
  description = "List of CIDR blocks for cidr ingress rules of the EC2 security group."
  default = [ 0 ]
}

variable "ingress_sg_from_port" {
  type        = list(number)
  description = "List of starting ports for sg ingress rules of the EC2 security group."
  default = [ 0 ]
}

variable "ingress_sg_to_port" {
  type        = list(number)
  description = "List of ending ports for sg ingress rules of the EC2 security group."
  default = [ 0 ]
}

variable "ingress_sg_protocol" {
  type        = list(string)
  description = "List of protocols for sg ingress rules of the EC2 security group."
  default = [ 0 ]
}

variable "ingress_security_group_ids" {
  type        = list(string)
  default     = [ "sg-0fe4363da3994c100" ]
  description = "List of Security Group ids for sg ingress rules of the EC2 security group."
}

variable "egress_cidr_from_port" {
  type        = list(number)
  description = "List of starting ports for cidr egress rules of the EC2 security group."
  default = [ 0 ]
}

variable "egress_cidr_to_port" {
  type        = list(number)
  description = "List of ending ports for cidr egress rules of the EC2 security group."
  default = [ 0 ]
}

variable "egress_cidr_protocol" {
  type        = list(any)
  description = "List of protocols for cidr egress rules of the EC2 security group."
  default = [ 0 ]
}

variable "egress_cidr_block" {
  type        = list(string)
  description = "List of CIDR blocks for cidr egress rules of the EC2 security group."
  default = [ 0 ]
}

variable "egress_sg_from_port" {
  type        = list(number)
  description = "List of starting ports for sg egress rules of the EC2 security group."
  default = [ 0 ]
}

variable "egress_sg_to_port" {
  type        = list(number)
  description = "List of ending ports for sg egress rules of the EC2 security group."
  default = [ 0 ]
}

variable "egress_sg_protocol" {
  type        = list(any)
  description = "List of protocols for sg egress rules of the EC2 security group."
  default = [ 0 ]
}

variable "egress_security_group_ids" {
  type        = list(string)
  default     = [ "sg-0fe4363da3994c100" ]
  description = "List of Security Group ids for sg egress rules of the EC2 security group."
}

variable "create_ingress_cidr" {
  type        = bool
  description = "Enable or disable CIDR block ingress rules."
  default = false
}

variable "create_ingress_sg" {
  type        = bool
  description = "Enable or disable Security Groups ingress rules."
  default = false
}

variable "create_egress_cidr" {
  type        = bool
  description = "Enable or disable CIDR block egress rules."
  default = false
}

variable "create_egress_sg" {
  type        = bool
  description = "Enable or disable Security Groups egress rules."
  default = false
}

variable "common_tags" {
  type = map(string)
  default = {}
}