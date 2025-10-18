resource "aws_efs_mount_target" "this" {
  for_each = { for idx, id in var.subnet_id : idx => id }
  file_system_id = aws_efs_file_system.this.id
  subnet_id      = each.value
  security_groups = var.security_groups
}

resource "aws_efs_file_system" "this" {
  creation_token = var.name
      tags = merge({Name = "${var.name}"}, var.common_tags)
}