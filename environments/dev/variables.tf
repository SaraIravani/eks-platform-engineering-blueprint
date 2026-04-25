variable "name" {
  description = "Name prefix for dev environment resources."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name used for subnet discovery tags."
  type        = string
}

variable "region" {
  description = "AWS region for regional resources and endpoints."
  type        = string
}

variable "azs" {
  description = "Availability Zones for the VPC subnets."
  type        = list(string)
}

variable "vpc_cidr" {
  description = "CIDR block for the dev VPC."
  type        = string
}

variable "public_subnets" {
  description = "Public subnet CIDRs, one per AZ."
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnet CIDRs, one per AZ."
  type        = list(string)
}

variable "tags" {
  description = "Default tags applied to dev resources."
  type        = map(string)
  default     = {}
}
