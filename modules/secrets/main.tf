
# --- Placeholder for best Practice ---

/*# --- DB Password ---
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
*/
