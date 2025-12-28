output "alb_dns_name" {
  value       = try(module.application_alb.alb_dns_name, null)
  description = "ALB DNS name"
}

output "app_url" {
  value       = format("%s://%s.%s", var.enable_https ? "https" : "http", var.subdomain, var.domain_name)
  description = "Public URL for the application (protocol follows enable_https)"
}

output "bastion_public_ip" {
  value       = module.bastion.public_ip
  description = "Bastion host public IP"
}

output "rds_endpoint" {
  value       = module.rds.db_endpoint
  description = "RDS endpoint"
}

output "artifact_bucket" {
  value       = module.s3_artifacts.bucket_name
  description = "Artifact S3 bucket name"
}

