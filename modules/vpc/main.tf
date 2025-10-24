
# --------------- VPC & Subnets ----------------- #

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
  map_public_ip_on_launch = false
  tags = merge({Name = each.value.name}, var.common_tags)
}

resource "aws_subnet" "data" {
  for_each = { for subnet in var.data_subnets : subnet.name => subnet }
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = false
  tags = merge({Name = each.value.name}, var.common_tags)
}

# --------------- Route Table ----------------- #

resource "aws_route_table" "public" {
  count = length(aws_subnet.public)
  vpc_id = aws_vpc.this.id
  tags = merge({Name = "${var.name}-public-rt-${upper
  (substr(values(aws_subnet.public)[count.index].availability_zone,-1, 1))}"}, 
  var.common_tags)
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  subnet_id = values(aws_subnet.public)[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}

resource "aws_route_table" "app" {
  count = length(aws_subnet.app)
  vpc_id = aws_vpc.this.id
  tags = merge({Name = "${var.name}-app-rt-${upper
  (substr(values(aws_subnet.app)[count.index].availability_zone,-1, 1))}"}, 
  var.common_tags)
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.this[count.index].id
  }
}

resource "aws_route_table_association" "app" {
  count = length(aws_subnet.app)
  subnet_id = values(aws_subnet.app)[count.index].id
  route_table_id = aws_route_table.app[count.index].id
}

resource "aws_route_table" "data" {
  count = length(aws_subnet.data)
  vpc_id = aws_vpc.this.id
  tags = merge({Name = "${var.name}-data-rt-${upper
  (substr(values(aws_subnet.data)[count.index].availability_zone,-1, 1))}"}, 
  var.common_tags)
}

resource "aws_route_table_association" "data" {
  count = length(aws_subnet.data)
  subnet_id = values(aws_subnet.data)[count.index].id
  route_table_id = aws_route_table.data[count.index].id
}

# --------------- IGW ----------------- #

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge({Name = "${var.name}-igw"}, var.common_tags)
}

# --------------- NGW ----------------- #

resource "aws_eip" "this" {
  count = length(aws_subnet.public)
  domain = "vpc"
  tags = merge({Name = "${var.name}-eip-${count.index}"}, var.common_tags)
}

resource "aws_nat_gateway" "this" {
  count = length(aws_subnet.public)
  allocation_id = aws_eip.this[count.index].id
  subnet_id = values(aws_subnet.public)[count.index].id
  connectivity_type = "public"
  tags = merge({Name = "${var.name}-ngw-${count.index}"}, var.common_tags)
}

# --------------- Interface Endpoint ----------------- #

resource "aws_vpc_endpoint" "aws-ssm-int-endpoint" {
  vpc_id = aws_vpc.this.id
  subnet_ids = [for subnet in aws_subnet.app : subnet.id]
  service_name = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"
  security_group_ids = var.endpoint_security_group_ids
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "aws-ssm-ec2-messages" {
  vpc_id = aws_vpc.this.id
  subnet_ids = [for subnet in aws_subnet.app : subnet.id]
  service_name = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type = "Interface"
  security_group_ids = var.endpoint_security_group_ids
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "aws-ssm-messages" {
  vpc_id = aws_vpc.this.id
  subnet_ids = [for subnet in aws_subnet.app : subnet.id]
  service_name = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"
  security_group_ids = var.endpoint_security_group_ids
  private_dns_enabled = true
}
