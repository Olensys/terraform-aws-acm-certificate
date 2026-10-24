# Changelog

## [1.0.3](https://github.com/Olensys/terraform-aws-acm-certificate/compare/v1.0.2...v1.0.3) (2026-10-24)


### Bug Fixes

* **examples:** unique application slug so concurrent integration runs do not collide ([#2](https://github.com/Olensys/terraform-aws-acm-certificate/issues/2)) ([565d019](https://github.com/Olensys/terraform-aws-acm-certificate/commit/565d0190d317dc9e9eba2b93a0e0e0a5263c9d3b))

## [1.0.2](https://github.com/Olensys/terraform-aws-acm-certificate/compare/v1.0.1...v1.0.2) (2026-10-24)


### Bug Fixes

* run integration on change and weekly instead of nightly ([a588c89](https://github.com/Olensys/terraform-aws-acm-certificate/commit/a588c89029fa6845ea78df5941aeba9f8ae8e6ad))

## 1.0.1

### Fixes

- render declared provider constraints and skip .terraform in trivy scans
- declare terraform and provider versions in examples
- de-duplicate validation records by record name

## 1.0.0

- ACM certificate with DNS validation, EC P-256 key and create-before-destroy.
- `validation.method = "route53"` creates the records and waits for issuance; `"external"` emits `validation_records` in the `terraform-cloudflare-dns` record shape.
- Wraps `terraform-aws-modules/acm/aws` 6.3.1.
