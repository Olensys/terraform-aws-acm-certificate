variable "name" {
  description = "Resource name. Lowercase letters, digits and hyphens."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]{1,63}$", var.name))
    error_message = "name must match ^[a-z0-9-]{1,63}$."
  }
}

variable "context" {
  description = "Deployment context used for naming, tagging and environment-dependent defaults."
  type = object({
    organization = string
    environment  = string
    application  = string
    component    = optional(string)
    owner        = string
    cost_center  = string
    extra_tags   = optional(map(string), {})
  })
  validation {
    condition     = contains(["dev", "staging", "prod", "test", "shared"], var.context.environment)
    error_message = "context.environment must be one of dev, staging, prod, test, shared."
  }
}

variable "create" {
  description = "Whether to create any resources. Set false to create nothing."
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "Primary domain name of the certificate (for example example.com or *.example.com). This is the certificate's identity; var.name is used for tagging only."
  type        = string
  validation {
    condition     = length(var.domain_name) >= 1 && length(var.domain_name) <= 253
    error_message = "domain_name must be between 1 and 253 characters."
  }
}

variable "subject_alternative_names" {
  description = "Additional domain names the certificate covers."
  type        = list(string)
  default     = []
}

variable "validation" {
  description = "DNS validation settings. method is route53 (the module creates the records in zone_id and, when wait is true, waits for issuance) or external (the module emits validation_records for the consumer to create elsewhere; pass the created records' FQDNs back in external_record_fqdns to make the module wait for issuance). An empty list still turns the wait on; pass null to skip it."
  type = object({
    method                = string
    zone_id               = optional(string)
    wait                  = optional(bool, true)
    external_record_fqdns = optional(list(string))
  })
  validation {
    condition     = contains(["route53", "external"], var.validation.method)
    error_message = "validation.method must be one of route53, external."
  }
  validation {
    condition     = var.validation.method != "route53" || try(length(var.validation.zone_id) > 0, false)
    error_message = "validation.zone_id must be set when validation.method is route53."
  }
  validation {
    condition     = var.validation.method != "route53" || var.validation.external_record_fqdns == null
    error_message = "external_record_fqdns is only used with method external."
  }
}

variable "tags" {
  description = "Tags merged onto every taggable resource, applied last."
  type        = map(string)
  default     = {}
}
