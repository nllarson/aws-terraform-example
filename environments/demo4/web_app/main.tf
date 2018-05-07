provider "aws" {
  profile = "aws-meetup"
}

data "aws_vpc" "vpc" {
  tags {
    Name        = "${var.environment}-vpc"
    Environment = "${var.environment}"
  }
}

data "aws_subnet_ids" "subnets" {
  vpc_id = "${data.aws_vpc.vpc.id}"
}

##################################
# LOAD BALANCER
##################################

module "web_app_load_balancer" {
  source      = "../../../modules/loadbalancer"
  environment = "${var.environment}"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  subnets     = "${data.aws_subnet_ids.subnets.ids}"
}

##################################
# EC2
##################################

module "web_app_servers" {
  source = "../../../modules/web_server"

  environment                    = "${var.environment}"
  instance_count                 = 4
  vpc_id                         = "${data.aws_vpc.vpc.id}"
  subnets                        = "${data.aws_subnet_ids.subnets.ids}"
  key_name                       = "aws-meetup"
  whitelisted_ips                = "${var.whitelisted_ips}"
  loadbalancer_target_group_arn  = "${module.web_app_load_balancer.target_group_arn}"
  loadbalancer_security_group_id = "${module.web_app_load_balancer.security_group_id}"
}
