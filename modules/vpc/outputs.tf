output "vpc_id" {
    value = aws_vpc.this.id
}

output "sn_public_id" {
    value = [for s in aws_subnet.public : s.id]
}

output "sn_app_id" {
    value = [for s in aws_subnet.app : s.id]
}

output "sn_data_id" {
    value = [for s in aws_subnet.data : s.id]
}