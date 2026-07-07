module "vpc_cloud" {
  source       = "./modules/vpc-cloud"
  vpc_cidr     = var.cloud_vpc_cidr
  project_name = var.project_name
  aws_region   = var.aws_region
}

module "vpc_onprem" {
  source       = "./modules/vpc-onprem"
  vpc_cidr     = var.onprem_vpc_cidr
  project_name = var.project_name
  aws_region   = var.aws_region
  my_ip        = var.my_ip
}

module "ec2" {
  source                  = "./modules/ec2"
  project_name            = var.project_name
  my_ip                   = var.my_ip
  public_key_path         = var.public_key_path
  cloud_vpc_id            = module.vpc_cloud.vpc_id
  cloud_private_subnet_id = module.vpc_cloud.private_subnet_id
  onprem_public_subnet_id = module.vpc_onprem.public_subnet_id
  onprem_cgw_sg_id        = module.vpc_onprem.cgw_sg_id
}

module "vpn" {
  source        = "./modules/vpn"
  project_name  = var.project_name
  vgw_id        = module.vpc_cloud.vgw_id
  cgw_public_ip = module.ec2.onprem_cgw_public_ip
}