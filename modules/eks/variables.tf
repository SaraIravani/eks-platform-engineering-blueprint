variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "cluster_version" {
  type        = string
  description = "EKS Kubernetes version"
}

variable "cluster_role_arn" {
  type        = string
  description = "IAM role ARN for EKS control plane"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for EKS control plane"
}

variable "endpoint_private_access" {
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  type        = bool
  default     = false
}

variable "enabled_cluster_log_types" {
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}
