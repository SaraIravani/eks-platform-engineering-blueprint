variable "name" { type = string }
variable "cluster_name" { type = string }
variable "region" { type = string }
variable "azs" { type = list(string) }
variable "cidr_block" { type = string }
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "single_nat_gateway" { type = bool default = false }
variable "enable_interface_endpoints" { type = bool default = true }
variable "tags" { type = map(string) default = {} }
