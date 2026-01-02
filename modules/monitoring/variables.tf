variable "project_name" {}
variable "sns_alert_email" {}
variable "target_group_arn" {}
variable "tags" { type = map(string) }
variable "alb_name" {}
variable "tg_name" {}
variable "asg_instance_ids" {
	type = list(string)
	default = []
}

