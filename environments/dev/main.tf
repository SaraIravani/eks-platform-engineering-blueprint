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
