variable "environment" {
  type        = "string"
  description = "The environment being built"
}

variable "instance_count" {
  description = "Number of instances to create"
  default     = 2
}

variable "key_name" {
  type        = "string"
  description = "The EC2 Key-Pair name used to build the instance"
}

variable "ami_id" {
  type        = "string"
  description = "AMI ID used to build the instance"
  default     = "ami-1853ac65"
}

variable "instance_type" {
  type        = "string"
  description = "The EC2 instance type"
  default     = "t2.micro"
}

variable "vpc_id" {
  type        = "string"
  description = "Id of the VPC for the intended environment"
}

variable "subnets" {
  type        = "list"
  description = "List of subnets used to create the instances."
}

variable "whitelisted_ips" {
  type        = "list"
  description = "Whitelisted IPs"
}

variable "loadbalancer_target_group_arn" {
  description = "Loadbalancer Target Group ARN to add each www instance to."
}

variable "loadbalancer_security_group_id" {
  description = "Load balancer security group used to allow traffic to each www instance"
}

variable "target_port" {
  description = "Port recieving traffice from target group attachement"
  default     = 80
}

variable "config_script" {
  type        = "string"
  description = "Location of script used to initialize server (base provisioning)"
  default     = "conf/setup.sh"
}

variable "config_connection_type" {
  type        = "string"
  description = "Protocol used to make initial connection to server for base provisioning"
  default     = "ssh"
}

variable "config_connection_user" {
  type    = "string"
  default = "ec2-user"
}
