module "vpc" {
  source = "../../modules/vpc"

  env_code     = var.env_code
  vpc_cidr     = var.vpc_cidr
  private_cidr = var.private_cidr
  public_cidr  = var.public_cidr
}

module "eks" {
  source = "../../modules/eks"
  
  env_code     = var.env_code
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnet_id
}

