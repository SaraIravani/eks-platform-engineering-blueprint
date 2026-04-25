output "vpc_id" {
  description = "VPC ID created for the dev environment."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs in the dev environment."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs in the dev environment."
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_ids" {
  description = "NAT gateway IDs in the dev environment."
  value       = module.vpc.nat_gateway_ids
}

output "vpc_endpoint_ids" {
  description = "VPC endpoint IDs in the dev environment."
  value       = module.vpc.vpc_endpoint_ids
}
