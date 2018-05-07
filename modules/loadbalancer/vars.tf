variable "environment" {
  type        = "string"
  description = "The environment being built"
}

variable "vpc_id" {
  type        = "string"
  description = "Id of the VPC for the intended environment"
}

variable "subnets" {
  type        = "list"
  description = "List of subnets used to create the instances."
}

variable "target_group_port" {
  description = "Port used to send traffic to in target group"
  default     = 80
}

variable "target_group_protocol" {
  type        = "string"
  description = "Protocol used to send traffic to target group"
  default     = "HTTP"
}

variable "target_group_health_check_port" {
  description = "Port used to check health of target group instances"
  default     = 80
}

variable "listener_port" {
  description = "Port used to listen for traffic to load balancer"
  default     = 80
}

variable "listener_protocol" {
  type        = "string"
  description = "Protocol used to listen for traffic to load balancer"
  default     = "HTTP"
}
