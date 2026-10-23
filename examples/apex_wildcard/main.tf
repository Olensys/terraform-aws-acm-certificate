terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 6.0, < 7.0" }
  }
}

module "this" {
  source = "../../"

  name = "example"
  context = {
    organization = "olensys"
    environment  = "test"
    application  = "example"
    owner        = "platform"
    cost_center  = "eng"
  }

  domain_name               = "example.com"
  subject_alternative_names = ["*.example.com"]
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
