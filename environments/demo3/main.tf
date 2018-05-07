provider "aws" {
  profile = "aws-meetup"
}

##################################
# VPC
##################################

module "vpc" {
  source             = "../../modules/vpc"
  environment        = "${var.environment}"
  vpc_cidr_block     = "${var.vpc_cidr}"
  availability_zones = "${var.availability_zones}"
  subnet_count       = 2
}

##################################
# LOAD BALANCER
##################################

module "load_balancer" {
  source      = "../../modules/loadbalancer"
  environment = "${var.environment}"
  vpc_id      = "${module.vpc.id}"
  subnets     = "${module.vpc.subnets}"
}

##################################
# EC2
##################################

module "web_servers" {
  source = "../../modules/web_server"

  environment                    = "${var.environment}"
  instance_count                 = 4
  vpc_id                         = "${module.vpc.id}"
  subnets                        = "${module.vpc.subnets}"
  key_name                       = "aws-meetup"
  whitelisted_ips                = "${var.whitelisted_ips}"
  loadbalancer_target_group_arn  = "${module.load_balancer.target_group_arn}"
  loadbalancer_security_group_id = "${module.load_balancer.security_group_id}"
}
