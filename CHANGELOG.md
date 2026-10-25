# Changelog

## [1.1.1](https://github.com/Olensys/terraform-aws-acm-certificate/compare/v1.1.0...v1.1.1) (2026-10-25)


### Bug Fixes

* **examples:** request the apex_wildcard certificate under the test subdomain ([#9](https://github.com/Olensys/terraform-aws-acm-certificate/issues/9)) ([423eb7e](https://github.com/Olensys/terraform-aws-acm-certificate/commit/423eb7eb40cf87c50783e16d658450be474ba9ee))
* **examples:** validate the example certificate through Cloudflare ([#7](https://github.com/Olensys/terraform-aws-acm-certificate/issues/7)) ([958415d](https://github.com/Olensys/terraform-aws-acm-certificate/commit/958415d81b2a1011c22039a6b8c9a69401460f9f))

## [1.1.0](https://github.com/Olensys/terraform-aws-acm-certificate/compare/v1.0.3...v1.1.0) (2026-10-25)


### Features

* wait for issuance with external DNS validation ([#4](https://github.com/Olensys/terraform-aws-acm-certificate/issues/4)) ([4e2d532](https://github.com/Olensys/terraform-aws-acm-certificate/commit/4e2d532a917890f772fbcc133fa122c6b30cea12))

### Behaviour changes

With `validation.method = "external"`, passing `validation.external_record_fqdns` makes the module wait for issuance; `arn` and `id` then depend on that wait. Without it behaviour is unchanged.

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
