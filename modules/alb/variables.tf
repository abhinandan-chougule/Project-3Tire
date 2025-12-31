variable "project_name" {}
variable "vpc_id" {}
variable "public_subnet_ids" { type = list(string) }
variable "alb_certificate_arn" {
  type    = string
  default = null
}

variable "target_port" { type = number }
variable "alb_security_group_id" { type = string }
variable "tags" { type = map(string) }
variable "enable_https" {
  type    = bool
  default = false
}

variable "domain_name" {
  type        = string
  description = "Primary domain name for ACM certificate"
  default     = null
}

variable "alb_certificate_domain" {
  type        = string
  description = "Optional alternate domain name"
  default     = null
}

variable "hosted_zone_id" {
  type        = string
  description = "Route53 Hosted Zone ID for DNS validation"
  default     = null
}
