variable "cluster_name" { type = string }
variable "node_role_arn" { type = string }
variable "subnet_ids" { type = list(string) }
variable "tags" { type = map(string) default = {} }

variable "node_groups" {
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
