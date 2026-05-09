variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_autoscaler_role_arn" {
  description = "IAM role ARN for Cluster Autoscaler IRSA"
  type        = string
}
