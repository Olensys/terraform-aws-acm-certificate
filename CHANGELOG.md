# Changelog

## 1.0.1

### Fixes

- render declared provider constraints and skip .terraform in trivy scans
- declare terraform and provider versions in examples
- de-duplicate validation records by record name

## 1.0.0

- ACM certificate with DNS validation, EC P-256 key and create-before-destroy.
- `validation.method = "route53"` creates the records and waits for issuance; `"external"` emits `validation_records` in the `terraform-cloudflare-dns` record shape.
- Wraps `terraform-aws-modules/acm/aws` 6.3.1.
