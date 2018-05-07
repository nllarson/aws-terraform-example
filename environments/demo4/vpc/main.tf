provider "aws" {
  profile = "aws-meetup"
}

module "vpc" {
  source             = "../../../modules/vpc"
  environment        = "${var.environment}"
  vpc_cidr_block     = "${var.vpc_cidr}"
  availability_zones = "${var.availability_zones}"
  subnet_count       = 2
}
