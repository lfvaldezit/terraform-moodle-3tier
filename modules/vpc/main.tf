
resource "random_string" "this" {
  length  = 8
  upper   = true
  lower   = true
  special = false
  numeric = true
}

# --------------- VPC & Subnet ----------------- #

resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = merge({Name = var.name}, var.common_tags)
}

resource "aws_subnet" "public" {
  for_each = { for subnet in var.public_subnets : subnet.name => subnet }
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  tags = merge({Name = each.value.name}, var.common_tags)
}

resource "aws_subnet" "app" {
  for_each = { for subnet in var.app_subnets : subnet.name => subnet }
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  tags = merge({Name = each.value.name}, var.common_tags)
}

resource "aws_subnet" "data" {
  for_each = { for subnet in var.data_subnets : subnet.name => subnet }
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  tags = merge({Name = each.value.name}, var.common_tags)
}

# --------------- Route Table ----------------- #

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = merge({Name = "${var.name}-public-rt"}, var.common_tags)
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "app" {
  vpc_id = aws_vpc.this.id
  tags = merge({Name = "${var.name}-app-rt"}, var.common_tags)
}

resource "aws_route_table_association" "app" {
  for_each = aws_subnet.app
  subnet_id      = each.value.id
  route_table_id = aws_route_table.app.id
}

resource "aws_route_table" "data" {
  vpc_id = aws_vpc.this.id
  tags = merge({Name = "${var.name}-data-rt"}, var.common_tags)
}

resource "aws_route_table_association" "data" {
  for_each = aws_subnet.data
  subnet_id      = each.value.id
  route_table_id = aws_route_table.data.id
}

# --------------- IGW ----------------- #

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge({Name = "${var.name}-igw"}, var.common_tags)
}

# --------------- NGW ----------------- #

# resource "aws_eip" "this" {
#   depends_on = [ aws_internet_gateway.this ]
#   for_each = {for subnet in var.public_subnets : subnet.name => subnet}
#   region = var.region
#   domain = "vpc"
#   tags = merge({Name = "${var.name}-eip-${random_string.this.result}"}, var.common_tags)
# }

# resource "aws_nat_gateway" "this" {
#   for_each = {for subnet in var.public_subnets : subnet.name => subnet}
#   allocation_id = aws_eip.this[each.key].id
#   subnet_id     = aws_subnet.public[each.key].id
#   connectivity_type = "public"
#   tags = merge({Name = "${var.name}-ngw-a"}, var.common_tags)
#   depends_on = [aws_eip.this]
# }
