locals {
  tags = merge(var.context.extra_tags, var.tags)

  route53 = var.validation.method == "route53"

  # Wiring passed to the upstream module, exposed through outputs.
  route53_records_created = local.route53
  external_waits          = !local.route53 && var.validation.wait && var.validation.external_record_fqdns != null
  validation_waits        = (local.route53 && var.validation.wait) || local.external_waits

  # Group by record name: an apex and its wildcard share one DNS record.
  validation_options_by_record = var.create ? {
    for dvo in module.this.acm_certificate_domain_validation_options :
    trimsuffix(dvo.resource_record_name, ".") => dvo...
  } : {}
}

# Upstream applies create_before_destroy to the certificate itself.
module "this" {
  source  = "terraform-aws-modules/acm/aws"
  version = "6.3.1"

  create_certificate        = var.create
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names

  validation_method = "DNS"
  key_algorithm     = var.key_algorithm

  zone_id                = local.route53 ? var.validation.zone_id : null
  create_route53_records = local.route53_records_created
  validate_certificate   = local.route53
  wait_for_validation    = local.route53 && var.validation.wait

  tags = merge(local.tags, { Name = var.name })
}

resource "aws_acm_certificate_validation" "external" {
  count = var.create && local.external_waits ? 1 : 0

  certificate_arn         = module.this.acm_certificate_arn
  validation_record_fqdns = var.validation.external_record_fqdns
}
