provider "aws" {
  profile = "aws-meetup"
}


##################################
# S3 Backend
##################################

terraform {
  backend "s3" {
    bucket  = "aws-meetup-terraform-state"
    key     = "demos/demo4/vpc/terraform.tfstate"
    region  = "us-east-1"
    profile = "aws-meetup"
  }
}

module "vpc" {
  source             = "../../../modules/vpc"
  environment        = "${var.environment}"
  vpc_cidr_block     = "${var.vpc_cidr}"
  availability_zones = "${var.availability_zones}"
  subnet_count       = 2
}
