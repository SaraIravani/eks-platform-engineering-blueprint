terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.region

  default_tags {
    tags = local.tags
  }
}

locals {
  environment = "dev"
  name_prefix = "${var.project}-${local.environment}"

  tags = merge(
    {
      Environment = local.environment
      Project     = var.project
      ManagedBy   = "terraform"
      Owner       = var.owner
    },
    var.tags
  )
}

module "vpc" {
  source = "../../modules/vpc"

  name                    = local.name_prefix
  cluster_name            = var.cluster_name
  region                  = var.region
  azs                     = var.azs
  cidr_block              = var.vpc_cidr
  public_subnets          = var.public_subnets
  private_subnets         = var.private_subnets
  single_nat_gateway      = var.single_nat_gateway
  enable_interface_endpoints = var.enable_interface_endpoints
  tags                    = local.tags
}

module "iam" {
  source = "../../modules/iam"

  cluster_name      = var.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.cluster_oidc_issuer_hostpath
  tags              = local.tags
}

module "eks" {
  source = "../../modules/eks"

  cluster_name             = var.cluster_name
  cluster_version          = var.cluster_version
  cluster_role_arn         = module.iam.eks_cluster_role_arn
  subnet_ids               = module.vpc.private_subnet_ids
  endpoint_private_access  = true
  endpoint_public_access   = false
  cluster_log_retention_days = var.cluster_log_retention_days
  kms_key_deletion_window_in_days = 30
  tags                     = local.tags
}

module "addons" {
  source = "../../modules/addons"

  cluster_name     = module.eks.cluster_name
  ebs_csi_role_arn = module.iam.ebs_csi_role_arn
  tags             = local.tags
}

module "node_groups" {
  source = "../../modules/node_groups"

  cluster_name  = module.eks.cluster_name
  node_role_arn = module.iam.eks_node_group_role_arn
  subnet_ids    = module.vpc.private_subnet_ids
  node_groups   = var.node_groups
  tags          = local.tags

  depends_on = [module.addons]
}
