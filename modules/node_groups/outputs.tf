output "node_group_names" {
  description = "Names of the EKS managed node groups"
  value       = { for k, ng in aws_eks_node_group.this : k => ng.node_group_name }
}

output "node_group_arns" {
  description = "ARNs of the EKS managed node groups"
  value       = { for k, ng in aws_eks_node_group.this : k => ng.arn }
}
