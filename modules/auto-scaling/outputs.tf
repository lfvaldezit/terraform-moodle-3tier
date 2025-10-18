output "alb_dns_name" {
    value = aws_alb.this.dns_name
}

output "alb_listener_arn" {
    value = aws_lb_listener.this.arn
}