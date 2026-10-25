terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 6.0, < 7.0" }
  }
}

variable "zone_domain" {
  description = "Delegated test subdomain; the example requests apex.<zone_domain> plus its wildcard."
  type        = string
  default     = "tf-test.olensys.com"
}

module "this" {
  source = "../../"

  name = "olensys-test-acm-apex"
  context = {
    organization = "olensys"
    environment  = "test"
    application  = "acm"
    owner        = "platform"
    cost_center  = "eng"
  }

  domain_name               = "apex.${var.zone_domain}"
  subject_alternative_names = ["*.apex.${var.zone_domain}"]
  validation                = { method = "external", wait = false }
}

output "arn" {
  description = "ARN of the certificate."
  value       = module.this.arn
}

output "validation_records" {
  description = "DNS records to create so the certificate validates."
  value       = module.this.validation_records
}
