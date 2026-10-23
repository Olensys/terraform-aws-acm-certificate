locals {
  tags = merge(var.context.extra_tags, var.tags)

  route53 = var.validation.method == "route53"

  # Wiring passed to the upstream module, exposed through outputs.
  route53_records_created = local.route53
  validation_waits        = local.route53 && var.validation.wait
}

# Upstream applies create_before_destroy to the certificate itself.
module "this" {
  source  = "terraform-aws-modules/acm/aws"
  version = "6.3.1"

  create_certificate        = var.create
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names

  validation_method = "DNS"
  key_algorithm     = "EC_prime256v1"

  zone_id                = local.route53 ? var.validation.zone_id : null
  create_route53_records = local.route53_records_created
  validate_certificate   = local.route53
  wait_for_validation    = local.validation_waits

  tags = merge(local.tags, { Name = var.name })
}
