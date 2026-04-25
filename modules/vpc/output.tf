output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "CIDR block configured on the VPC."
  value       = aws_vpc.this.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the internet gateway attached to the VPC."
  value       = aws_internet_gateway.this.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets."
  value       = aws_subnet.private[*].id
}

output "nat_gateway_ids" {
  description = "IDs of NAT gateways."
  value       = aws_nat_gateway.this[*].id
}

output "private_route_table_ids" {
  description = "IDs of private route tables."
  value       = aws_route_table.private[*].id
}

output "vpc_endpoint_ids" {
  description = "Map of VPC endpoint IDs for gateway and interface endpoints."
  value = {
    s3       = aws_vpc_endpoint.s3.id
    dynamodb = aws_vpc_endpoint.dynamodb.id
    ecr_api  = aws_vpc_endpoint.ecr_api.id
    ecr_dkr  = aws_vpc_endpoint.ecr_dkr.id
  }
}

output "vpce_security_group_id" {
  description = "Security group ID used by interface endpoints."
  value       = aws_security_group.vpce.id
}
