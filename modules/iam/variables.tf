variable "cluster_name" { type = string }
variable "oidc_provider_arn" { type = string default = null }
variable "oidc_provider_url" { type = string default = null }
variable "tags" { type = map(string) default = {} }
