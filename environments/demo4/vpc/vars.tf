variable "environment" {
  default = "demo4"
}

variable "vpc_cidr" {
  default = "10.150.12.0/22"
}

variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b"]
}
