output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}

data "aws_instances" "asg_members" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-app"]
  }
}

output "asg_instance_ids" {
  description = "List of instance IDs currently in the ASG"
  value       = data.aws_instances.asg_members.ids
}
