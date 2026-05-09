locals {
  nat_gateway_count = var.single_nat_gateway ? 1 : length(var.azs)
}
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(var.tags, { Name = var.name })
}
resource "aws_internet_gateway" "this" { vpc_id = aws_vpc.this.id tags = merge(var.tags, { Name = "${var.name}-igw" }) }
resource "aws_subnet" "public" {
  count = length(var.public_subnets)
  vpc_id = aws_vpc.this.id
  cidr_block = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = merge(var.tags, { Name = "${var.name}-public-${count.index}", "kubernetes.io/role/elb" = "1", "kubernetes.io/cluster/${var.cluster_name}" = "shared" })
}
resource "aws_subnet" "private" {
  count = length(var.private_subnets)
  vpc_id = aws_vpc.this.id
  cidr_block = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]
  tags = merge(var.tags, { Name = "${var.name}-private-${count.index}", "kubernetes.io/role/internal-elb" = "1", "kubernetes.io/cluster/${var.cluster_name}" = "shared" })
}
resource "aws_eip" "nat" { count = local.nat_gateway_count domain = "vpc" tags = merge(var.tags, { Name = "${var.name}-nat-eip-${count.index}" }) }
resource "aws_nat_gateway" "this" {
  count         = local.nat_gateway_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = merge(var.tags, { Name = "${var.name}-nat-${count.index}" })
  depends_on    = [aws_internet_gateway.this]
}
resource "aws_route_table" "public" { vpc_id = aws_vpc.this.id tags = merge(var.tags, { Name = "${var.name}-public-rt" }) }
resource "aws_route" "public_internet" { route_table_id = aws_route_table.public.id destination_cidr_block = "0.0.0.0/0" gateway_id = aws_internet_gateway.this.id }
resource "aws_route_table_association" "public" { count = length(var.public_subnets) subnet_id = aws_subnet.public[count.index].id route_table_id = aws_route_table.public.id }
resource "aws_route_table" "private" { count = length(var.private_subnets) vpc_id = aws_vpc.this.id tags = merge(var.tags, { Name = "${var.name}-private-rt-${count.index}" }) }
resource "aws_route" "private_nat" {
  count = length(var.private_subnets)
  route_table_id = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.this[var.single_nat_gateway ? 0 : count.index].id
}
resource "aws_route_table_association" "private" { count = length(var.private_subnets) subnet_id = aws_subnet.private[count.index].id route_table_id = aws_route_table.private[count.index].id }
resource "aws_vpc_endpoint" "s3" { vpc_id = aws_vpc.this.id service_name = "com.amazonaws.${var.region}.s3" vpc_endpoint_type = "Gateway" route_table_ids = aws_route_table.private[*].id tags = merge(var.tags, { Name = "${var.name}-s3-endpoint" }) }
resource "aws_vpc_endpoint" "dynamodb" { vpc_id = aws_vpc.this.id service_name = "com.amazonaws.${var.region}.dynamodb" vpc_endpoint_type = "Gateway" route_table_ids = aws_route_table.private[*].id tags = merge(var.tags, { Name = "${var.name}-dynamodb-endpoint" }) }
resource "aws_security_group" "vpce" {
  count = var.enable_interface_endpoints ? 1 : 0
  name = "${var.name}-vpce-sg"
  description = "Security group for interface VPC endpoints"
  vpc_id = aws_vpc.this.id
  ingress { from_port = 443 to_port = 443 protocol = "tcp" cidr_blocks = [var.cidr_block] }
  egress { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = ["0.0.0.0/0"] }
  tags = merge(var.tags, { Name = "${var.name}-vpce-sg" })
}
resource "aws_vpc_endpoint" "ecr_api" {
  count = var.enable_interface_endpoints ? 1 : 0
  vpc_id = aws_vpc.this.id service_name = "com.amazonaws.${var.region}.ecr.api" vpc_endpoint_type = "Interface"
  subnet_ids = aws_subnet.private[*].id security_group_ids = [aws_security_group.vpce[0].id] private_dns_enabled = true
  tags = merge(var.tags, { Name = "${var.name}-ecr-api-endpoint" })
}
resource "aws_vpc_endpoint" "ecr_dkr" {
  count = var.enable_interface_endpoints ? 1 : 0
  vpc_id = aws_vpc.this.id service_name = "com.amazonaws.${var.region}.ecr.dkr" vpc_endpoint_type = "Interface"
  subnet_ids = aws_subnet.private[*].id security_group_ids = [aws_security_group.vpce[0].id] private_dns_enabled = true
  tags = merge(var.tags, { Name = "${var.name}-ecr-dkr-endpoint" })
}
