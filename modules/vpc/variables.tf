variable "name" {
  description = "Name prefix used for VPC resources."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name used for Kubernetes subnet discovery tags."
  type        = string
}

variable "region" {
  description = "AWS region used to build regional VPC endpoint service names."
  type        = string
}

variable "azs" {
  description = "Availability Zones used for subnet and NAT gateway placement."
  type        = list(string)

  validation {
    condition     = length(var.azs) > 0
    error_message = "At least one availability zone must be provided."
  }
}

variable "cidr_block" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnets" {
  description = "List of CIDRs for public subnets; one per AZ."
  type        = list(string)

  validation {
    condition     = length(var.public_subnets) == length(var.azs)
    error_message = "public_subnets must have the same length as azs."
  }
}

variable "private_subnets" {
  description = "List of CIDRs for private subnets; one per AZ."
  type        = list(string)

  validation {
    condition     = length(var.private_subnets) == length(var.azs)
    error_message = "private_subnets must have the same length as azs."
  }
}

variable "tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
  default     = {}
}
