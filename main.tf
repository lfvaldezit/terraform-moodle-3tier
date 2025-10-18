resource "aws_ssm_parameter" "db_name" {
  name  = "/moodle/db_name"
  type  = "String"
  value = var.db_name
}

resource "aws_ssm_parameter" "db_username" {
  name  = "/moodle/db_user"
  type  = "String"
  value = var.db_username
}

resource "aws_ssm_parameter" "db_pass" {
  name  = "/moodle/db_pass"
  type  = "SecureString"
  value = var.db_pass
}

resource "aws_ssm_parameter" "db_host" {
  name  = "/moodle/RDSID"
  type  = "String"
  value = module.rds.rds_dns_name
}

resource "aws_ssm_parameter" "file_system" {
  name  = "/moodle/EFSID"
  type  = "String"
  value = module.efs.efs_dns_name
}

module "vpc" {
  source         = "./modules/vpc"
  name           = "${var.name}-vpc"
  cidr_block     = var.cidr_block
  public_subnets = var.public_subnets
  app_subnets    = var.app_subnets
  data_subnets   = var.data_subnets
  common_tags    = local.common_tags
  region         = local.aws_region
}

module "ec2_sg" {
  source = "./modules/security-group"
  name   = "${var.name}-sg-web"
  vpc_id = module.vpc.vpc_id

  create_ingress_cidr    = true
  ingress_cidr_block     = ["0.0.0.0/0", "0.0.0.0/0"]
  ingress_cidr_from_port = [80, 22]
  ingress_cidr_to_port   = [80, 22]
  ingress_cidr_protocol  = ["tcp", "tcp"]

  create_egress_cidr    = true
  egress_cidr_block     = ["0.0.0.0/0"]
  egress_cidr_from_port = [0]
  egress_cidr_to_port   = [0]
  egress_cidr_protocol  = [-1]
}

module "efs_sg" {
  source = "./modules/security-group"
  name   = "${var.name}-sg-efs"
  vpc_id = module.vpc.vpc_id

  create_ingress_sg          = true
  ingress_security_group_ids = [module.ec2_sg.id]
  ingress_sg_from_port       = [2049]
  ingress_sg_to_port         = [2049]
  ingress_sg_protocol        = ["tcp"]

  create_egress_cidr    = true
  egress_cidr_block     = ["0.0.0.0/0"]
  egress_cidr_from_port = [0]
  egress_cidr_to_port   = [0]
  egress_cidr_protocol  = [-1]
}

module "rds_sg" {
  source = "./modules/security-group"
  name   = "${var.name}-sg-rds"
  vpc_id = module.vpc.vpc_id

  create_ingress_sg          = true
  ingress_security_group_ids = [module.ec2_sg.id]
  ingress_sg_from_port       = [3306]
  ingress_sg_to_port         = [3306]
  ingress_sg_protocol        = ["tcp"]


  create_egress_cidr    = true
  egress_cidr_block     = ["0.0.0.0/0"]
  egress_cidr_from_port = [0]
  egress_cidr_to_port   = [0]
  egress_cidr_protocol  = [-1]
}

module "redis_sg" {
  source = "./modules/security-group"
  name   = "${var.name}-sg-redis"
  vpc_id = module.vpc.vpc_id

  create_ingress_sg          = true
  ingress_security_group_ids = [module.ec2_sg.id]
  ingress_sg_from_port       = [6379]
  ingress_sg_to_port         = [6379]
  ingress_sg_protocol        = ["tcp"]


  create_egress_cidr    = true
  egress_cidr_block     = ["0.0.0.0/0"]
  egress_cidr_from_port = [0]
  egress_cidr_to_port   = [0]
  egress_cidr_protocol  = [-1]
}

module "alb_sg" {
  source = "./modules/security-group"
  name   = "${var.name}-sg-alb"
  vpc_id = module.vpc.vpc_id

  create_ingress_cidr    = true
  ingress_cidr_block     = ["0.0.0.0/0", "0.0.0.0/0"]
  ingress_cidr_from_port = [80, 443]
  ingress_cidr_to_port   = [80, 443]
  ingress_cidr_protocol  = ["tcp", "tcp"]

  create_egress_cidr    = true
  egress_cidr_block     = ["0.0.0.0/0"]
  egress_cidr_from_port = [0]
  egress_cidr_to_port   = [0]
  egress_cidr_protocol  = [-1]
}

module "efs" {
  source          = "./modules/efs"
  name            = "${var.name}-EFS"
  subnet_id       = module.vpc.sn_app_id
  common_tags     = local.common_tags
  security_groups = [module.efs_sg.id]
}

module "rds" {
  source                 = "./modules/rds"
  name                   = "${var.name}-mariadb-db"
  engine                 = var.engine
  engine_version         = var.engine_version
  db_instance_type       = var.db_instance_type
  db_name                = aws_ssm_parameter.db_name.value
  db_username            = aws_ssm_parameter.db_username.value
  db_pass                = aws_ssm_parameter.db_pass.value
  subnet_id              = module.vpc.sn_data_id
  vpc_security_group_ids = [module.rds_sg.id]
  common_tags            = local.common_tags
}

module "redis" {
  source             = "./modules/elasticache"
  name               = "${var.name}-redis"
  node_type          = var.node_type
  security_group_ids = [module.redis_sg.id]
  subnet_ids         = module.vpc.sn_data_id
  common_tags        = local.common_tags
}

module "ec2" {
  depends_on         = [module.efs, module.rds]
  source             = "./modules/ec2"
  ec2_name           = "${var.name}-web-A"
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  security_group_ids = [module.ec2_sg.id]
  subnet_id          = module.vpc.sn_public_id[0]
  common_tags        = local.common_tags
  user_data          = <<-EOF
    #!/bin/bash -xe

    EFSID=$(/usr/bin/aws ssm get-parameters --region us-east-1 --names /moodle/EFSID --query Parameters[0].Value)
    EFSID=`echo $EFSID | sed -e 's/^"//' -e 's/"$//'`

    RDSID=$(/usr/bin/aws ssm get-parameters --region us-east-1 --names /moodle/RDSID --query Parameters[0].Value)
    RDSID=`echo $RDSID | sed -e 's/^"//' -e 's/"$//'`

    sudo yum install -y cronie httpd php php-mbstring php-xml  php-curl php-zip php-gd php-intl php-soap amazon-efs-utils mariadb1011 mariadb1011-server php-mysqlnd php-redis
    sudo wget https://download.moodle.org/download.php/direct/stable500/moodle-latest-500.tgz -P /var/www/html

    cd /var/www/html
    sudo tar -zxf moodle-latest-500.tgz
    sudo rm -rf moodle-latest-500.tgz

    mkdir /var/www/moodledata
    echo -e "$EFSID:/ /var/www/moodledata efs _netdev,tls,iam 0 0" | tee -a /etc/fstab
    sudo mount -a -t efs defaults

    sudo chmod 777 /var/www/moodledata -R
    sudo chown apache:apache /var/www/moodledata -R
    sudo chown apache:apache /var/www/html -R

    sudo sed -i "s/;max_input_vars = 1000/max_input_vars = 5000/g" /etc/php.ini
    sudo systemctl restart php-*
    sudo systemctl start httpd
    sudo systemctl enable httpd
    sudo systemctl start crond
    sudo systemctl enable crond

    echo "* * * * * /usr/bin/php /var/www/html/moodle/admin/cli/cron.php >/dev/null"  | sudo crontab -u apache -

    EOF
}

#---------------  ----------------- #

# module "acm" {
#   source                    = "terraform-aws-modules/acm/aws"
#   version                   = "5.1.0"
#   domain_name               = var.domain_name
#   #zone_id                   = var.zone_id
#   validation_method         = var.validation_method
#   subject_alternative_names = ["*.${var.domain_name}"]
#   create_route53_records    = var.create_route53_records
#   tags                      = local.common_tags
# }

# resource "aws_ssm_parameter" "record" {
#   name  = "/moodle/RECORD_NAME"
#   type  = "String"
#   value = module.root.hostname
# }

# module "asg" {
#   source                    = "../modules/auto-scaling"
#   name                      = var.name
#   ami_id                    = var.ami_id_ASG
#   instance_type             = var.instance_type
#   alb_secgrp_id             = [module.alb_sg.id]
#   launch_template_secgrp_id = [module.ec2_sg.id]
#   common_tags               = local.common_tags
#   subnets_id                = module.vpc.sn_public_id
#   vpc_id                    = module.vpc.vpc_id
#   health_check_path         = var.health_check_path
#   certificate_arn = module.acm.acm_certificate_arn
#   min_size                  = 1
#   max_size                  = 3
#   desired_capacity          = 1
#   user_data                 = <<-EOF
#     #!/bin/bash -xe

#     RECORD=$(/usr/bin/aws ssm get-parameters --region us-east-1 --names /moodle/RECORD_NAME --query Parameters[0].Value)
#     RECORD=`echo $RECORD | sed -e 's/^"//' -e 's/"$//'`

#     cd /var/www/html/moodle
#     sudo sed -i "/^\$CFG->admin.*/a \$CFG->sslproxy = true;" config.php
#     sudo sed -i "/^\$CFG->admin.*/a \$CFG->session_redis_acquire_lock_timeout = 120;" config.php
#     sudo sed -i "/^\$CFG->admin.*/a \$CFG->session_redis_lock_expire = 7200;" config.php
#     sudo sed -i "/^\$CFG->admin.*/a \$CFG->session_handler_class = '\\\\core\\\\session\\\\redis';" config.php
#     sudo sed -i "/^\$CFG->admin.*/a \$CFG->session_redis_host = '${redis_dns_name}';" config.php
#     sed -i "s|^\(\$CFG->wwwroot\s*=\s*\).*|\1'https://$RECORD/moodle';|" config.php

#    EOF
# }

# module "root" {
#   source = "../modules/cloudflare"
#   zone_id        = var.zone_id
#   record_name    = var.record_name
#   record_content = module.asg.alb_dns_name
# }