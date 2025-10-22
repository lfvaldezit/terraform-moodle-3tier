resource "aws_ssm_parameter" "admin_pass" {
  name = var.param_name
  type = var.type
  value = var.value
}
