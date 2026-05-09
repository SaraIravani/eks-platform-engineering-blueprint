project         = "eks-platform"
owner           = "platform-team"
cluster_name    = "eks-platform-dev"
region          = "ca-central-1"
cluster_version = "1.30"

azs             = ["ca-central-1a", "ca-central-1b"]
vpc_cidr        = "10.20.0.0/16"
public_subnets  = ["10.20.0.0/24", "10.20.1.0/24"]
private_subnets = ["10.20.10.0/24", "10.20.11.0/24"]

single_nat_gateway = true

tags = {
  CostCenter = "1234"
}

node_groups = {
  system = {
    instance_types = ["m6i.large"]
    capacity_type  = "ON_DEMAND"
    min_size       = 2
    max_size       = 4
    desired_size   = 2
    disk_size      = 50
    labels         = { workload = "system" }
    taints         = []
  }
  batch = {
    instance_types = ["m6a.large", "m5.large"]
    capacity_type  = "SPOT"
    min_size       = 0
    max_size       = 10
    desired_size   = 0
    disk_size      = 40
    labels         = { workload = "batch" }
    taints = [{
      key    = "workload"
      value  = "batch"
      effect = "NO_SCHEDULE"
    }]
  }
}
