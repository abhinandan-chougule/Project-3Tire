variable "project_name" {}
variable "vpc_id" {}
variable "private_subnet_ids" { type = list(string) }
variable "app_ami_id" {}
variable "instance_type" {}
variable "target_group_arn" {}
variable "artifact_bucket_name" {}
variable "artifact_object_key" {}
variable "db_security_group_id" {}
variable "app_security_group_id" {}
variable "alb_security_group_id" {}
variable "desired_capacity" { type = number }
variable "min_size" { type = number }
variable "max_size" { type = number }
variable "db_host" { type = string }
variable "db_port" { type = number }
variable "db_name" { type = string }
variable "db_username" { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}
variable "tags" { type = map(string) }

# AWS CLI version used when installing AWS CLI v2 in instance user-data
variable "aws_cli_version" {
  type        = string
  default     = "2.30.6"
  description = "Version string for AWS CLI v2 installer (e.g. 2.30.6)"
}
