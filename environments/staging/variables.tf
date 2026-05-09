variable "project" {
  description = "Project slug used for naming and tagging."
  type        = string
}

variable "owner" {
  description = "Owning team or business unit."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "region" {
  description = "AWS region."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for EKS."
  type        = string
}

variable "cluster_log_retention_days" {
  description = "CloudWatch retention period for EKS control-plane logs."
  type        = number
  default     = 30
}

variable "azs" { type = list(string) }
variable "vpc_cidr" { type = string }
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }

variable "single_nat_gateway" {
  description = "Use a single NAT gateway in non-production environments to reduce cost."
  type        = bool
  default     = true
}

variable "enable_interface_endpoints" {
  description = "Whether to create interface endpoints (ECR API/DKR)."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags."
  type        = map(string)
  default     = {}
}

variable "node_groups" {
  description = "Managed node group definitions."
  type = map(object({
    instance_types = list(string)
    capacity_type  = string
    min_size       = number
    max_size       = number
    desired_size   = number
    disk_size      = number
    labels         = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  }))
}
