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
