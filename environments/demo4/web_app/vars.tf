variable "environment" {
  default = "demo4"
}

variable "whitelisted_ips" {
  type        = "list"
  description = "Whitelisted IPs"
  default     = ["0.0.0.0/0"]
}
