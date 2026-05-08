module "vpc" {
  source = "../../modules/vpc"

  name            = var.name
  cluster_name    = var.cluster_name
  region          = var.region
  azs             = var.azs
  cidr_block      = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  tags            = var.tags
}
module "iam" {
  source = "../../modules/iam"

  cluster_name = var.cluster_name
}
module "eks" {
  source = "../../modules/eks"

  cluster_name     = var.cluster_name
  cluster_version  = var.cluster_version
  cluster_role_arn = module.iam.eks_cluster_role_arn

  subnet_ids = module.vpc.private_subnets

  endpoint_private_access = true
  endpoint_public_access  = false
}
