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
    condition     = alltrue([for r in values(output.validation_records) : r.type == "CNAME" && r.ttl == 300 && r.proxied == false])
    error_message = "validation records must be CNAME records in the terraform-cloudflare-dns shape."
  }
}
