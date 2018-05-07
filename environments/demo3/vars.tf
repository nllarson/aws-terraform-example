variable "environment" {
  default = "demo3"
}

variable "vpc_cidr" {
  default = "10.150.8.0/22"
}

variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b"]
}

variable "whitelisted_ips" {
  type        = "list"
  description = "Whitelisted IPs"
  default     = ["68.96.28.240/32"]
}
