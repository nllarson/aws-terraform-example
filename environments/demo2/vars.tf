variable "environment" {
  default = "demo2"
}

variable "vpc_cidr" {
  default = "10.150.4.0/22"
}

variable "ami_id" {
  description = "Base AMI"
  default     = "ami-1853ac65"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSH Key Name"
  default     = "aws-meetup"
}

variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b"]
}
