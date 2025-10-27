
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
  name = "${var.name}-ec2-profile"
  role = aws_iam_role.this.name
}

resource "aws_iam_role" "this" {
  name               = "${var.name}-role"
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

# --------------- Simple Auto Scaling Policy----------------- #

resource "aws_autoscaling_policy" "this" {
  count = length(var.autoscaling_policy)
  name                   = var.autoscaling_policy[count.index].name
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.this.name
  scaling_adjustment = var.autoscaling_policy[count.index].scaling_adjustment
  cooldown = var.autoscaling_policy[count.index].cooldown
}

resource "aws_cloudwatch_metric_alarm" "this" {
  count = length(var.cloudwatch_metric_alarm)
  alarm_name          = var.cloudwatch_metric_alarm[count.index].name
  comparison_operator = var.cloudwatch_metric_alarm[count.index].comparison_operator
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = var.cloudwatch_metric_alarm[count.index].threshold
  alarm_description   = var.cloudwatch_metric_alarm[count.index].alarm_description
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }
  alarm_actions = [aws_autoscaling_policy.this[count.index].arn]
}