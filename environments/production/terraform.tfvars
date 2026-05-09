project         = "eks-platform"
owner           = "platform-team"
cluster_name    = "eks-platform-prod"
region          = "ca-central-1"
cluster_version = "1.30"
azs             = ["ca-central-1a", "ca-central-1b", "ca-central-1d"]
vpc_cidr        = "10.40.0.0/16"
public_subnets  = ["10.40.0.0/24", "10.40.1.0/24", "10.40.2.0/24"]
private_subnets = ["10.40.10.0/24", "10.40.11.0/24", "10.40.12.0/24"]
single_nat_gateway = false
cluster_log_retention_days = 90
node_groups = {
  system = { instance_types=["m6i.xlarge"], capacity_type="ON_DEMAND", min_size=3, max_size=6, desired_size=3, disk_size=80, labels={workload="system"}, taints=[] }
  api    = { instance_types=["m6i.2xlarge"], capacity_type="ON_DEMAND", min_size=3, max_size=20, desired_size=6, disk_size=100, labels={workload="api"}, taints=[] }
  batch  = { instance_types=["m6a.xlarge","m5.xlarge"], capacity_type="SPOT", min_size=0, max_size=30, desired_size=0, disk_size=80, labels={workload="batch"}, taints=[{key="workload",value="batch",effect="NO_SCHEDULE"}] }
}
