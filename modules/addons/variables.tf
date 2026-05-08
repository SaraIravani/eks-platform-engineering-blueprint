variable "cluster_name" {
  description = "Name of the EKS cluster where core add-ons will be installed"
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL of the EKS cluster"
  type        = string
}

variable "ebs_csi_role_arn" {
  description = "IAM role ARN used by the EBS CSI driver service account"
  type        = string
}
