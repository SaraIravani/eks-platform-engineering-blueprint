output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster.arn
}

output "eks_node_group_role_arn" {
  value = aws_iam_role.eks_node_group.arn
}
output "ebs_csi_role_arn" {
  description = "IAM role ARN for EBS CSI driver IRSA"
  value       = try(aws_iam_role.ebs_csi[0].arn, null)
}
