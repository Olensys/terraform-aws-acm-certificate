output "id" {
  description = "Identifier of the certificate (its ARN). Null when create is false."
  value       = var.create ? module.this.acm_certificate_arn : null
}

output "name" {
  description = "Domain name of the certificate. Null when create is false."
  value       = var.create ? var.domain_name : null
}

output "arn" {
  description = "ARN of the ACM certificate. Null when create is false."
  value       = var.create ? module.this.acm_certificate_arn : null
}

output "validation_records" {
  description = "DNS validation records keyed by validated domain name, in the record shape consumed by terraform-cloudflare-dns (name, type, content, ttl, proxied, comment). Known only after apply. Null when create is false."
  value = var.create ? {
    for dvo in module.this.acm_certificate_domain_validation_options : dvo.domain_name => {
      name    = trimsuffix(dvo.resource_record_name, ".")
      type    = dvo.resource_record_type
      content = trimsuffix(dvo.resource_record_value, ".")
      ttl     = 300
      proxied = false
      comment = "ACM validation for ${dvo.domain_name}"
    }
  } : null
}

output "route53_records_created" {
  description = "Whether the module asks the upstream module to create the Route53 validation records. Null when create is false."
  value       = var.create ? local.route53_records_created : null
}

output "validation_waits" {
  description = "Whether the module waits for the certificate to be issued. Null when create is false."
  value       = var.create ? local.validation_waits : null
}

output "tags" {
  description = "Tags applied to every taggable resource, with context.extra_tags merged in. Null when create is false."
  value       = var.create ? local.tags : null
}
