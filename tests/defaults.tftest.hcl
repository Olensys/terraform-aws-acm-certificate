mock_provider "aws" {
  mock_resource "aws_acm_certificate" {
    defaults = {
      arn = "arn:aws:acm:us-east-1:123456789012:certificate/00000000-0000-0000-0000-000000000000"
      domain_validation_options = [{
        domain_name           = "example.com"
        resource_record_name  = "_abc.example.com."
        resource_record_type  = "CNAME"
        resource_record_value = "_def.acm-validations.aws."
      }]
    }
  }
}

variables {
  context = {
    organization = "olensys"
    environment  = "test"
    application  = "example"
    owner        = "platform"
    cost_center  = "eng"
  }
  name        = "example"
  domain_name = "example.com"
  validation = {
    method  = "route53"
    zone_id = "Z0000000000000000000"
  }
}

run "test_route53_creates_records_and_validation" {
  command = plan

  # SMOKE: asserts the wiring the wrapper passes upstream (record creation and
  # validation wait) through its own outputs; the certificate, records and
  # validation resources live in the child module, so the real check is
  # tests/complete.tftest.hcl.
  assert {
    condition     = output.route53_records_created == true
    error_message = "route53 method must create the validation records."
  }

  assert {
    condition     = output.validation_waits == true
    error_message = "route53 method must wait for validation by default."
  }

  assert {
    condition     = output.name == "example.com"
    error_message = "name output must be the certificate domain."
  }
}

run "test_route53_wait_can_be_disabled" {
  command = plan

  variables {
    validation = {
      method  = "route53"
      zone_id = "Z0000000000000000000"
      wait    = false
    }
  }

  # SMOKE: asserts the computed wiring only; see tests/complete.tftest.hcl.
  assert {
    condition     = output.validation_waits == false
    error_message = "validation.wait = false must disable waiting."
  }
}

run "test_external_emits_records_only" {
  command = plan

  variables {
    validation = { method = "external" }
  }

  # SMOKE: validation_records derives from domain_validation_options, which is
  # known only after apply, so plan cannot assert its content. Asserted here:
  # no Route53 records and no validation wait are requested. The records shape
  # is proven by tests/complete.tftest.hcl.
  assert {
    condition     = output.route53_records_created == false
    error_message = "external method must not create Route53 records."
  }

  assert {
    condition     = output.validation_waits == false
    error_message = "external method must not wait for validation."
  }
}

run "test_method_validation" {
  command = plan

  variables {
    validation = { method = "http" }
  }

  expect_failures = [var.validation]
}

run "test_zone_id_required_for_route53" {
  command = plan

  variables {
    validation = { method = "route53" }
  }

  expect_failures = [var.validation]
}

run "test_create_false_plans_nothing" {
  command = plan

  variables {
    create = false
  }

  assert {
    condition = alltrue([
      output.id == null,
      output.name == null,
      output.arn == null,
      output.validation_records == null,
      output.route53_records_created == null,
      output.validation_waits == null,
      output.tags == null,
    ])
    error_message = "every output must be null when create is false."
  }
}

run "test_name_length_validation" {
  command = plan

  variables {
    name = "Bad-Name"
  }

  expect_failures = [var.name]
}

run "test_tags_contract" {
  command = plan

  variables {
    tags = { Owner = "x" }
    context = {
      organization = "olensys"
      environment  = "test"
      application  = "example"
      owner        = "platform"
      cost_center  = "eng"
      extra_tags   = { Owner = "y", Team = "z" }
    }
  }

  assert {
    condition     = output.tags.Owner == "x"
    error_message = "var.tags must win over context.extra_tags."
  }

  assert {
    condition     = output.tags.Team == "z"
    error_message = "context.extra_tags must be merged into tags."
  }
}
