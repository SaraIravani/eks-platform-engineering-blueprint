variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "enable_efs" {
  description = "Whether to enable EFS shared storage"
  type        = bool
  default     = false
}
