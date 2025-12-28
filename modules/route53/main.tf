# Request ACM certificate in same region as ALB
resource "aws_acm_certificate" "alb_cert" {
  domain_name               = var.certificate_domain
  validation_method         = "DNS"
  tags                      = merge(var.tags, { Name = "${var.certificate_domain}-cert" })
}

# Create validation record
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.alb_cert.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = var.hosted_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "alb_cert_validation" {
  certificate_arn         = aws_acm_certificate.alb_cert.arn
  validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
}

output "acm_certificate_arn" {
  value = aws_acm_certificate_validation.alb_cert_validation.certificate_arn
}