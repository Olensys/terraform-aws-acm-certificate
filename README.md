# terraform-aws-acm-certificate

ACM certificate with Route53 or external DNS validation, EC P-256 key, create-before-destroy

## Opinions

- DNS validation only (`validation_method = "DNS"`); email validation is not exposed.
- EC P-256 key (`key_algorithm = "EC_prime256v1"`).
- `create_before_destroy` on the certificate (applied by the upstream module), so replacements never leave listeners without a certificate.
- `validation.method = "route53"` creates the validation records in `validation.zone_id` and, unless `validation.wait = false`, waits for issuance.
- `validation.method = "external"` creates no records and does not wait; the `validation_records` output is in the record shape of [terraform-cloudflare-dns](https://github.com/Olensys/terraform-cloudflare-dns) so it can be passed straight through. The map is keyed by record name and de-duplicated: an apex and its wildcard share one record, listed once with both domains in its comment. Pass the created records' FQDNs in `validation.external_record_fqdns` to make the module wait for issuance (and `arn`/`id` depend on that wait); without them the certificate validates on its own once the records exist and nothing waits.
- The certificate's identity is `domain_name`; `name` is used for the `Name` tag only.
- CloudFront requires the certificate in `us-east-1`: pass an aliased `aws` provider for that region from the consumer.

## Usage

```hcl
module "naming" {
  source  = "git::https://github.com/Olensys/terraform-null-naming.git?ref=v1.0.1"
  context = var.context
}

module "acm_certificate" {
  source  = "git::https://github.com/Olensys/terraform-aws-acm-certificate.git?ref=v1.1.0"
  name    = module.naming.name
  context = var.context

  domain_name = "example.com"
  validation  = { method = "external" }

  tags = module.naming.tags
}
```

### Validating through Cloudflare

```hcl
module "cert" {
  source  = "git::https://github.com/Olensys/terraform-aws-acm-certificate.git?ref=v1.1.0"
  name    = module.naming.name
  context = var.context

  domain_name = "example.com"
  validation = {
    method                = "external"
    external_record_fqdns = values(module.dns.fqdns)
  }
}

module "dns" {
  source  = "git::https://github.com/Olensys/terraform-cloudflare-dns.git?ref=v1.1.0"
  context = var.context

  zone_id = var.cloudflare_zone_id
  records = module.cert.validation_records
}
```

`validation_records` feeds `terraform-cloudflare-dns`, and the created records' names (`fqdns`, a map of record key to record name) go back in as `external_record_fqdns`, so the module waits for issuance and `arn`/`id` only resolve once the certificate is issued. On a first deploy, and whenever the certificate is replaced (domain or SAN change), apply the certificate alone first (`terraform apply -target=module.cert`), then apply everything; the validation record names are known only after the certificate exists.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0, < 7.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0, < 7.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_this"></a> [this](#module\_this) | terraform-aws-modules/acm/aws | 6.3.1 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_acm_certificate_validation.external](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_context"></a> [context](#input\_context) | Deployment context used for naming, tagging and environment-dependent defaults. | <pre>object({<br/>    organization = string<br/>    environment  = string<br/>    application  = string<br/>    component    = optional(string)<br/>    owner        = string<br/>    cost_center  = string<br/>    extra_tags   = optional(map(string), {})<br/>  })</pre> | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Primary domain name of the certificate (for example example.com or *.example.com). This is the certificate's identity; var.name is used for tagging only. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Resource name. Lowercase letters, digits and hyphens. | `string` | n/a | yes |
| <a name="input_validation"></a> [validation](#input\_validation) | DNS validation settings. method is route53 (the module creates the records in zone\_id and, when wait is true, waits for issuance) or external (the module emits validation\_records for the consumer to create elsewhere; pass the created records' FQDNs back in external\_record\_fqdns to make the module wait for issuance). An empty list still turns the wait on; pass null to skip it. | <pre>object({<br/>    method                = string<br/>    zone_id               = optional(string)<br/>    wait                  = optional(bool, true)<br/>    external_record_fqdns = optional(list(string))<br/>  })</pre> | n/a | yes |
| <a name="input_create"></a> [create](#input\_create) | Whether to create any resources. Set false to create nothing. | `bool` | `true` | no |
| <a name="input_subject_alternative_names"></a> [subject\_alternative\_names](#input\_subject\_alternative\_names) | Additional domain names the certificate covers. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags merged onto every taggable resource, applied last. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the ACM certificate. Null when create is false. |
| <a name="output_id"></a> [id](#output\_id) | Identifier of the certificate (its ARN). Null when create is false. |
| <a name="output_name"></a> [name](#output\_name) | Domain name of the certificate. Null when create is false. |
| <a name="output_route53_records_created"></a> [route53\_records\_created](#output\_route53\_records\_created) | Whether the module asks the upstream module to create the Route53 validation records. Null when create is false. |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to every taggable resource, with context.extra\_tags merged in. Null when create is false. |
| <a name="output_validation_records"></a> [validation\_records](#output\_validation\_records) | DNS validation records keyed by record name (each distinct record appears once, even when it validates several domains such as an apex and its wildcard), in the record shape consumed by terraform-cloudflare-dns (name, type, content, ttl, proxied, comment). Known only after apply. Null when create is false. |
| <a name="output_validation_waits"></a> [validation\_waits](#output\_validation\_waits) | Whether the module waits for the certificate to be issued (route53 with wait, or external with record FQDNs and wait). Null when create is false. |
<!-- END_TF_DOCS -->
