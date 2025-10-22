
module "engine" {
  source = "./modules/parameter-store"
  param_name = "/${var.name}/engine" 
  type = "String"
  value = var.engine
}

resource "aws_ssm_parameter" "db_name" {
  name  = "/${var.name}/db_name"
  type  = "String"
  value = var.db_name
}

resource "aws_ssm_parameter" "db_username" {
  name  = "/${var.name}/db_username"
  type  = "String"
  value = var.db_username
}

resource "aws_ssm_parameter" "db_pass" {
  name  = "/${var.name}/db_pass"
  type  = "SecureString"
  value = var.db_pass
}

resource "aws_ssm_parameter" "admin_user" {
  name = "/${var.name}/admin_user"
  type = "String"
  value = var.admin_user
}

resource "aws_ssm_parameter" "admin_pass" {
  name = "/${var.name}/admin_pass"
  type = "SecureString"
  value = var.admin_pass
}

resource "aws_ssm_parameter" "admin_email" {
  name = "/${var.name}/admin_email"
  type = "String"
  value = var.admin_email
}

resource "aws_ssm_parameter" "db_host" {
  name  = "/${var.name}/RDSID"
  type  = "String"
  value = module.rds.rds_dns_name
}

resource "aws_ssm_parameter" "file_system" {
  name  = "/${var.name}/EFSID"
  type  = "String"
  value = module.efs.efs_dns_name
}

resource "aws_ssm_parameter" "redis" {
  name  = "/${var.name}/REDIS"
  type  = "String"
  value = module.redis.cache_nodes[0].address
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
  depends_on         = [module.efs, module.rds, module.redis]
  source             = "./modules/ec2"
  ec2_name           = "${var.name}-web"
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  security_group_ids = [module.ec2_sg.id]
  subnet_id          = module.vpc.sn_public_id[0]
  common_tags        = local.common_tags
  user_data          = <<-EOF
    #!/bin/bash -xe

    REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
    PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

    # PARAMETER STORE DATA #

    EFSID=$(/usr/bin/aws ssm get-parameters --region $REGION --names /${var.name}/EFSID --query Parameters[0].Value)
    EFSID=`echo $EFSID | sed -e 's/^"//' -e 's/"$//'`

    RDSID=$(/usr/bin/aws ssm get-parameters --region $REGION --names /${var.name}/RDSID --query Parameters[0].Value)
    RDSID=`echo $RDSID | sed -e 's/^"//' -e 's/"$//'`

    REDIS=$(/usr/bin/aws ssm get-parameters --region $REGION --names /${var.name}/REDIS --query Parameters[0].Value)
    REDIS=`echo $REDIS | sed -e 's/^"//' -e 's/"$//'`

    DB_NAME=$(/usr/bin/aws ssm get-parameters --region $REGION --names /${var.name}/db_name --query Parameters[0].Value)
    DB_NAME=`echo $DB_NAME | sed -e 's/^"//' -e 's/"$//'`

    DB_USERNAME=$(/usr/bin/aws ssm get-parameters --region $REGION --names /${var.name}/db_username --query Parameters[0].Value)
    DB_USERNAME=`echo $DB_USERNAME | sed -e 's/^"//' -e 's/"$//'`

    DB_PASS=$(/usr/bin/aws ssm get-parameters --region $REGION --names /${var.name}/db_pass --with-decryption --query Parameters[0].Value)
    DB_PASS=`echo $DB_PASS | sed -e 's/^"//' -e 's/"$//'`

    ADMINUSER=$(/usr/bin/aws ssm get-parameters --region $REGION --names /${var.name}/admin_user --query Parameters[0].Value)
    ADMINUSER=`echo $ADMINUSER | sed -e 's/^"//' -e 's/"$//'`

    ADMINPASS=$(/usr/bin/aws ssm get-parameters --region $REGION --names /${var.name}/admin_pass --with-decryption --query Parameters[0].Value)
    ADMINPASS=`echo $ADMINPASS | sed -e 's/^"//' -e 's/"$//'`

    ADMINEMAIL=$(/usr/bin/aws ssm get-parameters --region $REGION --names /${var.name}/admin_email --query Parameters[0].Value)
    ADMINEMAIL=`echo $ADMINEMAIL | sed -e 's/^"//' -e 's/"$//'`

    ENGINE=$(/usr/bin/aws ssm get-parameters --region $REGION --names /${var.name}/engine --query Parameters[0].Value)
    ENGINE=`echo $ENGINE | sed -e 's/^"//' -e 's/"$//'`

    # PLUGINS #

    sudo yum install -y telnet stress cronie httpd php php-mbstring php-xml  php-curl php-zip php-gd php-intl php-soap amazon-efs-utils mariadb1011 mariadb1011-server php-mysqlnd php-redis
    sudo wget https://download.moodle.org/download.php/direct/stable500/moodle-latest-500.tgz -P /var/www/html

    cd /var/www/html
    sudo tar -zxf moodle-latest-500.tgz
    sudo rm -rf moodle-latest-500.tgz

    # MOUNT EFS #

    mkdir /var/www/moodledata
    echo -e "$EFSID:/ /var/www/moodledata efs _netdev,tls,iam 0 0" | tee -a /etc/fstab
    sudo mount -a -t efs defaults

    # PERMISSIONS #

    sudo chmod -R 777 /var/www/moodledata 
    sudo chown -R apache /var/www/moodledata 
    sudo chown -R apache /var/www/html 

    # ENVIRONMENT - MAX INPUT VARS #

    sudo sed -i "s/;max_input_vars = 1000/max_input_vars = 5000/g" /etc/php.ini

    # INSTALL MOODLE #

    /usr/bin/php /var/www/html/moodle/admin/cli/install.php \
    --chmod=0777 \
    --lang=en \
    --wwwroot="http://$PUBLIC_IP/moodle" \
    --dataroot="/var/www/moodledata" \
    --dbtype=$ENGINE \
    --dbhost=$RDSID \
    --dbport="3306" \
    --dbname=$DB_NAME \
    --dbuser=$DB_USERNAME \
    --dbpass=$DB_PASS \
    --fullname="Moodle AWS" \
    --shortname="Moodle" \
    --adminuser=$ADMINUSER \
    --adminpass=$ADMINPASS \
    --adminemail=$ADMINEMAIL \
    --non-interactive \
    --agree-license

    sudo chown -R apache /var/www/html/moodle

    # HEALTH CHECK FILE #

    cd /var/www/html/moodle
    echo "healthy" | sudo tee health.html

    # SESSION HANDLING #

    sudo sed -i "/^\$CFG->admin.*/a \$CFG->session_redis_acquire_lock_timeout = 120;" config.php
    sudo sed -i "/^\$CFG->admin.*/a \$CFG->session_redis_lock_expire = 7200;" config.php
    sudo sed -i "/^\$CFG->admin.*/a \$CFG->session_handler_class = '\\\\core\\\\session\\\\redis';" config.php
    sudo sed -i "/^\$CFG->admin.*/a \$CFG->session_redis_host = '$REDIS';" config.php

    # ENABLE & VERIFY SERVICES #

    sudo systemctl restart php-*
    sudo systemctl start httpd
    sudo systemctl enable httpd
    sudo systemctl start crond
    sudo systemctl enable crond
    sudo systemctl status httpd
    sudo systemctl status crond

    # SET UP CRON #

    echo "* * * * * /usr/bin/php /var/www/html/moodle/admin/cli/cron.php >/dev/null"  | sudo crontab -u apache -

    EOF
}

#---------------  ----------------- #

resource "aws_ssm_parameter" "hostname" {
  depends_on = [ module.alb ]
  name  = "/${var.name}/hostname"
  type  = "String"
  value = module.root.hostname
}

module "acm" {
  source                    = "terraform-aws-modules/acm/aws"
  version                   = "5.1.0"
  domain_name               = var.domain_name
  validation_method         = var.validation_method
  subject_alternative_names = ["*.${var.domain_name}"]
  create_route53_records    = var.create_route53_records
  tags                      = local.common_tags
}

module "alb" {
  source = "./modules/load-balancer"
  name = var.name
  vpc_id = module.vpc.vpc_id
  health_check_path = var.health_check_path
  certificate_arn = module.acm.acm_certificate_arn
  alb_secgrp_id = [module.alb_sg.id]
  subnets_id = module.vpc.sn_public_id
  common_tags =  local.common_tags
}

module "root" {
  depends_on = [ module.alb ]
  source = "./modules/cloudflare"
  zone_id        = var.zone_id
  record_name    = var.record_name
  record_content = module.alb.alb_dns_name
}

module "asg" {
  depends_on = [ module.alb ]
  source = "./modules/auto-scaling"
  name = var.name
  vpc_id = module.vpc.vpc_id
  ami_id = var.ami_id_ASG
  instance_type = var.instance_type
  source_instance_id = module.ec2.id
  launch_template_secgrp_id = [module.ec2_sg.id]
  subnets_id = module.vpc.sn_public_id
  target_group_id = module.alb.target_group_id
  min_size = 1
  max_size = 2
  desired_capacity = 1
  common_tags = local.common_tags
  user_data                 = <<-EOF
    #!/bin/bash -xe

    HOSTNAME=$(/usr/bin/aws ssm get-parameters --region us-east-1 --names /${var.name}/hostname --query Parameters[0].Value)
    HOSTNAME=`echo $HOSTNAME | sed -e 's/^"//' -e 's/"$//'`

    cd /var/www/html/moodle

    sudo sed -i "/^\$CFG->admin.*/a \$CFG->sslproxy = true;" config.php
    sed -i "s|^\(\$CFG->wwwroot\s*=\s*\).*|\1'https://$HOSTNAME';|" config.php

   EOF
}