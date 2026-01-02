
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.sns_alert_email
}


resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"
  tags = var.tags
}



# Alarm on Unhealthy hosts in target group
resource "aws_cloudwatch_metric_alarm" "tg_unhealthy" {
  alarm_name          = "${var.project_name}-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 1
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"

  dimensions = {
    TargetGroup  = var.tg_name
    LoadBalancer = var.alb_name
  }

  alarm_description  = "Unhealthy hosts detected in target group"
  treat_missing_data = "missing"

  actions_enabled = true
  alarm_actions   = [aws_sns_topic.alerts.arn]
  ok_actions      = [aws_sns_topic.alerts.arn]
}

# alarm on high CPU utilization for each instance in the ASG
resource "aws_cloudwatch_metric_alarm" "cpu_high_instance" {
  for_each = toset(var.asg_instance_ids)

  alarm_name          = "${var.project_name}-cpu-high-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 60
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"

  dimensions = {
    InstanceId = each.key
  }

  alarm_description  = "CPU utilization exceeds 60% on instance ${each.key}"
  treat_missing_data = "missing"

  actions_enabled = true
  alarm_actions   = [aws_sns_topic.alerts.arn]
  ok_actions      = [aws_sns_topic.alerts.arn]
}

