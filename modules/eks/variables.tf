variable "cluster_name" { type = string }
variable "cluster_version" { type = string }
variable "cluster_role_arn" { type = string }
variable "subnet_ids" { type = list(string) }
variable "endpoint_private_access" { type = bool default = true }
variable "endpoint_public_access" { type = bool default = false }
variable "enabled_cluster_log_types" {
  type    = list(string)
  default = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}
variable "cluster_log_retention_days" { type = number default = 30 }
variable "kms_key_deletion_window_in_days" { type = number default = 30 }
variable "tags" { type = map(string) default = {} }
