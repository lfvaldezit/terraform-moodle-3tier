output "alb_dns_name" {
    value = aws_alb.this.dns_name
}

output "target_group_id" {
    value = aws_lb_target_group.this.id
}