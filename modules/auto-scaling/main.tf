resource "random_string" "this" {
  length  = 8
  upper   = true
  lower   = true
  special = false
  numeric = true
}

# --------------- Launch Template ----------------- #

resource "aws_launch_template" "this" {
    name = "${var.name}-launch-template"
    image_id = var.ami_id
    instance_type = var.instance_type
    iam_instance_profile {
        name = aws_iam_instance_profile.this.name
    }
    vpc_security_group_ids = var.launch_template_secgrp_id
    user_data = base64encode(var.user_data)
    tags = merge({Name = "${var.name}-launch-template"}, var.common_tags)
}

# --------------- Target Group  ----------------- #

resource "aws_lb_target_group" "this" {
  name        = "${var.name}-tg-grp"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  health_check {
    path = var.health_check_path
  }
  tags = merge({Name = "${var.name}-tgtgrp"}, var.common_tags)
}

resource "aws_autoscaling_attachment" "example" {
  autoscaling_group_name = aws_autoscaling_group.this.id
  lb_target_group_arn    = aws_lb_target_group.this.id
}

# --------------- Load Balancer  ----------------- #

resource "aws_alb" "this" {
    name = "${var.name}-alb-web"
    internal = false
    load_balancer_type = "application"
    security_groups = var.alb_secgrp_id
    subnets = var.subnets_id
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_alb.this.arn
  # port              = "80"
  # protocol          = "HTTP"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# https://docs.moodle.org/500/en/Apache#Load_Balancer_Hints_(AWS)

resource "aws_lb_listener_rule" "rule-1" {

  condition {
    path_pattern {
      values = ["*/.*", "*/upgrade.txt", "*/db/install.xml", "*/README.md", "*/composer.json"]
    }
  }

  action {
    type = "fixed-response"
    target_group_arn = aws_lb_target_group.this.arn
    fixed_response {
      status_code = 404
      content_type = "text/html"
      message_body = "<html>\n<head><title>404 Not Found</title></head>\n<body>\n<center><h1>404 Not Found</h1></center>\n<hr>\n</body>\n</html>" 
    }
  }

  listener_arn = aws_lb_listener.this.arn
}

resource "aws_lb_listener_rule" "rule-2" {

  condition {
    path_pattern {
      values = ["*/composer.json", "*/Gruntfile.js", "*.lock", "*/environtment.xml", "*/readme.txt"]
    }
  }

  action {
    type = "fixed-response"
    target_group_arn = aws_lb_target_group.this.arn
    fixed_response {
      status_code = 404
      content_type = "text/html"
      message_body = "<html>\n<head><title>404 Not Found</title></head>\n<body>\n<center><h1>404 Not Found</h1></center>\n<hr>\n</body>\n</html>" 
    }
  }

  listener_arn = aws_lb_listener.this.arn
}

resource "aws_lb_listener_rule" "rule-3" {

  condition {
    path_pattern {
      values = ["*/fixtures/*", "*/behat/*", "*/phpunit.xml", "*/health.html"]
    }
  }

  action {
    type = "fixed-response"
    target_group_arn = aws_lb_target_group.this.arn
    fixed_response {
      status_code = 404
      content_type = "text/html"
      message_body = "<html>\n<head><title>404 Not Found</title></head>\n<body>\n<center><h1>404 Not Found</h1></center>\n<hr>\n</body>\n</html>" 
    }
  }

  listener_arn = aws_lb_listener.this.arn
}

# --------------- Auto Scaling Group  ----------------- #

resource "aws_autoscaling_group" "this" {
    name = "${var.name}-asg"
    min_size = var.min_size
    max_size = var.max_size
    desired_capacity = var.desired_capacity
    vpc_zone_identifier = var.subnets_id
    health_check_type = "ELB"

    tag{
      key = "Name"
      value = "${var.name}-ec2-asg"
      propagate_at_launch = true
    }

    launch_template {
        id = aws_launch_template.this.id
        version = aws_launch_template.this.latest_version
    }
}

# --------------- IAM ROLE ----------------- #

resource "aws_iam_instance_profile" "this" {
  name = "ec2-inst-profile-${random_string.this.result}"
  role = aws_iam_role.this.name
}

resource "aws_iam_role" "this" {
  name               = "ec2-role-${random_string.this.result}"
  assume_role_policy = <<EOF
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole",
        "Condition": {}
        }
    ]
    }
EOF    
}

resource "aws_iam_role_policy_attachment" "ec2-role-ssm-instance-core" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "efs-full-access" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
}

# --------------- Auto Scaling Simple Policies----------------- #

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "simple-scale-up-75"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.this.name
  scaling_adjustment = "1"
  cooldown = 300
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "simple-scale-down-35"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.this.name
  scaling_adjustment = "-1"
  cooldown = 300
}

resource "aws_cloudwatch_metric_alarm" "cpu_util_up_75" {
  alarm_name          = "cpu_util_up_75"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 75
  alarm_description   = "Trigger scale out when CPU > 75%"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_util_down_35" {
  alarm_name          = "cpu_util_down_35"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 35
  alarm_description   = "Trigger scale out when CPU < 35%"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_down.arn]
}
