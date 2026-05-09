output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Private API endpoint for EKS cluster."
  value       = module.eks.cluster_endpoint
}

output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs used by worker nodes."
  value       = module.vpc.private_subnet_ids
}

output "node_group_names" {
  description = "Managed node group names."
  value       = module.node_groups.node_group_names
}
