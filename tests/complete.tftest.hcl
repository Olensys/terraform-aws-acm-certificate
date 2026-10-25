# Run only by the nightly integration workflow, against real cloud credentials.
run "apply_minimal" {
  command = apply

  module {
    source = "./examples/minimal"
  }

  assert {
    condition     = length(output.validation_records) > 0
    error_message = "external validation must emit DNS validation records."
  }

  assert {
    condition     = output.arn != null
    error_message = "the certificate must be issued, so arn resolves from the validation wait."
  }

  assert {
    condition     = alltrue([for r in values(output.validation_records) : r.type == "CNAME" && r.ttl == 300 && r.proxied == false])
    error_message = "validation records must be CNAME records in the terraform-cloudflare-dns shape."
  }
}

# Apex plus wildcard share a single DNS validation record. Requires TF_VAR_zone_domain (defaults to the test subdomain); nothing waits for issuance.
run "apply_apex_and_wildcard" {
  command = apply

  module {
    source = "./examples/apex_wildcard"
  }

  assert {
    condition     = length(output.validation_records) == 1
    error_message = "apex.<zone_domain> + *.apex.<zone_domain> must emit exactly one validation record."
  }
}
