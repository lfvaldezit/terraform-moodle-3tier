
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

# --------------- Load Balancer  ----------------- #

resource "aws_alb" "this" {
    depends_on = [ aws_lb_target_group.this ]
    name = "${var.name}-alb-web"
    internal = false
    load_balancer_type = "application"
    security_groups = var.alb_secgrp_id
    subnets = var.subnets_id
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_alb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# --------------- Listener Rules  ----------------- #
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