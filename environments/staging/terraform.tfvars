project         = "eks-platform"
owner           = "platform-team"
cluster_name    = "eks-platform-staging"
region          = "ca-central-1"
cluster_version = "1.30"
azs             = ["ca-central-1a", "ca-central-1b"]
vpc_cidr        = "10.30.0.0/16"
public_subnets  = ["10.30.0.0/24", "10.30.1.0/24"]
private_subnets = ["10.30.10.0/24", "10.30.11.0/24"]
single_nat_gateway = false
node_groups = {
  system = { instance_types=["m6i.large"], capacity_type="ON_DEMAND", min_size=2, max_size=6, desired_size=2, disk_size=50, labels={workload="system"}, taints=[] }
  apps   = { instance_types=["m6a.large","m5.large"], capacity_type="SPOT", min_size=1, max_size=12, desired_size=2, disk_size=50, labels={workload="apps"}, taints=[] }
}
