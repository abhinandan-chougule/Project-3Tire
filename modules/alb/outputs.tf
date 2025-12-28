output "target_group_arn" {
  value = aws_lb_target_group.app.arn
}

output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "alb_name" {
  value = aws_lb.this.name
}

output "tg_name" {
  value = aws_lb_target_group.app.name
}

output "alb_listener_port" {
  value = var.enable_https ? 443 : 80
}

output "certificate_arn" {
  value = var.alb_certificate_arn
}