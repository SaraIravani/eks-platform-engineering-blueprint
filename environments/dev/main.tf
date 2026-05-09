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
module "addons" {
  source = "../../modules/addons"

  cluster_name            = module.eks.cluster_name
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  ebs_csi_role_arn        = module.iam.ebs_csi_role_arn

  depends_on = [module.eks]
}
module "node_groups" {
  source = "../../modules/node_groups"

  cluster_name  = module.eks.cluster_name
  node_role_arn = module.iam.eks_node_group_role_arn
  subnet_ids    = module.vpc.private_subnets
  node_groups   = var.node_groups

  depends_on = [
    module.eks,
    module.addons
  ]
}
module "scheduling" {
  source = "../../modules/scheduling"

  namespaces = ["api", "batch", "data", "security", "ingestion"]

  depends_on = [module.node_groups]
}
