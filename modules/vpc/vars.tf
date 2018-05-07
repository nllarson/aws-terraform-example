variable "environment" {
  type        = "string"
  description = "The environment being built"
}

variable "subnet_count" {
  description = "Number of subnets to create"
  default     = 2
}

variable "vpc_cidr_block" {
  description = "CIDR block used to create the VPC"
}

variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b"]
}
