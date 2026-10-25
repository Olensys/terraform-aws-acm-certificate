terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws        = { source = "hashicorp/aws", version = ">= 6.0, < 7.0" }
    cloudflare = { source = "cloudflare/cloudflare", version = ">= 5.0, < 6.0" }
  }
}

variable "zone_id" {
  description = "Cloudflare zone ID of the test zone the validation record is created in."
  type        = string
}

variable "zone_domain" {
  description = "Domain of the Cloudflare test zone; the certificate is issued for acm.<zone_domain>."
  type        = string
  default     = "tf-test.olensys.com"
}

module "this" {
  source = "../../"

  name = "olensys-test-acm"
  context = {
    organization = "olensys"
    environment  = "test"
    application  = "acm"
    owner        = "platform"
    cost_center  = "eng"
  }

  domain_name = "acm.${var.zone_domain}"
  validation = {
    method                = "external"
    external_record_fqdns = [cloudflare_dns_record.validation.name]
  }
}

# One domain, no SANs: exactly one validation record, so a static key keeps for_each plannable.
locals { validation = one(values(module.this.validation_records)) }

resource "cloudflare_dns_record" "validation" {
  zone_id = var.zone_id
  name    = local.validation.name
  type    = local.validation.type
  content = local.validation.content
  ttl     = 60
}

output "arn" {
  description = "ARN of the certificate; resolves only once it is issued."
  value       = module.this.arn
}

output "validation_records" {
  description = "DNS records that validate the certificate."
  value       = module.this.validation_records
}
