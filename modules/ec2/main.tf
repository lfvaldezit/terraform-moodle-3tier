resource "random_string" "this" {
  length  = 8
  upper   = true
  lower   = true
  special = false
  numeric = true
}

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

resource "aws_instance" "this" {
    depends_on = [ aws_iam_instance_profile.this ]
    ami = var.ami_id
    instance_type = var.instance_type
    security_groups = var.security_group_ids
    tags = merge({Name = "${var.ec2_name}"}, var.common_tags)
    subnet_id = var.subnet_id
    iam_instance_profile = aws_iam_instance_profile.this.name
    user_data = var.user_data
    associate_public_ip_address = true
    metadata_options {
      http_endpoint = "enabled"
      http_tokens = "optional"
    }
}
