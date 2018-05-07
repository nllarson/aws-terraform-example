variable "environment" {
  default = "demo4"
}

variable "whitelisted_ips" {
  type        = "list"
  description = "Whitelisted IPs"
  default     = ["68.96.28.240/32"]
}
