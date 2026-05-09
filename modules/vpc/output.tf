output "vpc_id" { value = aws_vpc.this.id }
output "public_subnet_ids" { value = aws_subnet.public[*].id }
output "private_subnet_ids" { value = aws_subnet.private[*].id }
output "nat_gateway_ids" { value = aws_nat_gateway.this[*].id }
output "vpc_endpoint_ids" {
  value = {
    s3       = aws_vpc_endpoint.s3.id
    dynamodb = aws_vpc_endpoint.dynamodb.id
    ecr_api  = try(aws_vpc_endpoint.ecr_api[0].id, null)
    ecr_dkr  = try(aws_vpc_endpoint.ecr_dkr[0].id, null)
  }
}
