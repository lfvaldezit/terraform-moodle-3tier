resource "random_string" "this" {
  length  = 8
  upper   = true
  lower   = true
  special = false
  numeric = true
}

# --------------- AMI ----------------- #

resource "aws_ami_from_instance" "example" {
  name               = "${var.name}-AMI"
  source_instance_id = var.source_instance_id 
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


resource "aws_autoscaling_attachment" "example" {
  autoscaling_group_name = aws_autoscaling_group.this.id
  lb_target_group_arn    = var.target_group_id
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
