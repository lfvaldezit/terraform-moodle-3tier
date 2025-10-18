resource "aws_db_instance" "this" {
  identifier = var.name
  allocated_storage    = 10
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.db_instance_type
  db_name                 = var.db_name
  username             = var.db_username
  password             = var.db_pass
  skip_final_snapshot  = true
  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name = aws_db_subnet_group.this.name
  tags = merge({Name = var.name}, var.common_tags)
}                                                                                                                    


resource "aws_db_subnet_group" "this" {
  subnet_ids = var.subnet_id
  tags = merge({Name = "${var.name}"}, var.common_tags)
}