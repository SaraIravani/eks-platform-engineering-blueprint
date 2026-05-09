name         = "dev-eks"
cluster_name = "dev-eks-cluster"
region       = "ca-central-1"

azs = [
  "ca-central-1a",
  "ca-central-1b"
]

vpc_cidr = "10.0.0.0/16"

public_subnets = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_subnets = [
  "10.0.10.0/24",
  "10.0.11.0/24"
]

tags = {
  Environment = "dev"
  Project     = "eks-platform"
  Owner       = "platform-team"
}
cluster_version = "1.30"
node_groups = {
  system = {
    instance_types = ["t3.medium"]
    capacity_type  = "ON_DEMAND"
    min_size       = 2
    max_size       = 4
    desired_size   = 2
    disk_size      = 30

    labels = {
      workload = "system"
      lifecycle = "on-demand"
    }

    taints = [
      {
        key    = "workload"
        value  = "system"
        effect = "NO_SCHEDULE"
      }
    ]
  }
}
