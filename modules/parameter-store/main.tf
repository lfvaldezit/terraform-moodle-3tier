resource "aws_ssm_parameter" "this" {
  name = var.param_name
  type = var.type
  value = var.value
}
