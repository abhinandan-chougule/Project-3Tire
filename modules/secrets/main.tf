# --- DB Password ---
resource "aws_secretsmanager_secret" "db_password" {
  name        = "${var.project_name}-db-password"
  description = "RDS password for PetClinic appuser"
}

resource "aws_secretsmanager_secret_version" "db_password_value" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.db_password
}

# --- SNS Email ---
resource "aws_secretsmanager_secret" "sns_email" {
  name        = "${var.project_name}-sns-email"
  description = "CloudWatch alarm notification email"
}

resource "aws_secretsmanager_secret_version" "sns_email_value" {
  secret_id     = aws_secretsmanager_secret.sns_email.id
  secret_string = var.sns_alert_email
}

# --- Domain Name ---
resource "aws_secretsmanager_secret" "domain_name" {
  name        = "${var.project_name}-domain-name"
  description = "Root domain for Route53"
}

resource "aws_secretsmanager_secret_version" "domain_name_value" {
  secret_id     = aws_secretsmanager_secret.domain_name.id
  secret_string = var.domain_name
}

# --- ALB Certificate Domain ---
resource "aws_secretsmanager_secret" "alb_cert_domain" {
  name        = "${var.project_name}-alb-cert-domain"
  description = "Subdomain for ALB SSL certificate"
}

resource "aws_secretsmanager_secret_version" "alb_cert_domain_value" {
  secret_id     = aws_secretsmanager_secret.alb_cert_domain.id
  secret_string = var.alb_certificate_domain
}