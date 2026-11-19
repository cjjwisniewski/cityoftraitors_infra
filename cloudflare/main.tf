data "cloudflare_zone" "cityoftraitors" {
  name = "cityoftraitors.com"
}

resource "cloudflare_record" "root_cname" {
  zone_id = data.cloudflare_zone.cityoftraitors.id
  name    = "@"
  content = "cityoftraitorscom.z20.web.core.windows.net"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "www_cname" {
  zone_id = data.cloudflare_zone.cityoftraitors.id
  name    = "www"
  content = "cityoftraitorscom.z20.web.core.windows.net"
  type    = "CNAME"
  proxied = true
}

# Best Practices Zone Settings
resource "cloudflare_zone_settings_override" "cityoftraitors_settings" {
  zone_id = data.cloudflare_zone.cityoftraitors.id

  settings {
    always_use_https         = "on"
    automatic_https_rewrites = "on"
    brotli                   = "on"
    email_obfuscation        = "off"
    rocket_loader            = "off"
    security_level           = "medium"
    ssl                      = "full"

    security_header {
      enabled            = true
      max_age            = 31536000
      include_subdomains = true
      nosniff            = true
    }
  }
}

# Redirect www to root domain (modern Redirect Ruleset replacing deprecated Page Rule)
resource "cloudflare_ruleset" "www_to_root" {
  zone_id     = data.cloudflare_zone.cityoftraitors.id
  name        = "cityoftraitors.com WWW to Root Redirect"
  description = "301 redirect www.cityoftraitors.com to https://cityoftraitors.com preserving path and query"
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"

  rules {
    action      = "redirect"
    expression  = "(http.host eq \"www.cityoftraitors.com\")"
    description = "Redirect www to root"
    enabled     = true

    action_parameters {
      from_value {
        status_code           = 301
        preserve_query_string = true

        target_url {
          expression = "concat(\"https://cityoftraitors.com\", http.request.uri.path)"
        }
      }
    }
  }
}

# Edge Cache Rules for static HTML & assets on cityoftraitors.com and seeker.cityoftraitors.com
resource "cloudflare_ruleset" "cache_rules" {
  zone_id     = data.cloudflare_zone.cityoftraitors.id
  name        = "cityoftraitors.com Static Site Cache Rules"
  description = "Cache static HTML and assets at Cloudflare edge respecting origin Cache-Control"
  kind        = "zone"
  phase       = "http_request_cache_settings"

  rules {
    action      = "set_cache_settings"
    expression  = "(http.host in {\"cityoftraitors.com\" \"seeker.cityoftraitors.com\"} and not starts_with(http.request.uri.path, \"/api/\"))"
    description = "Cache static HTML and assets respecting origin Cache-Control"
    enabled     = true

    action_parameters {
      cache = true

      edge_ttl {
        mode = "respect_origin"
      }

      browser_ttl {
        mode = "respect_origin"
      }
    }
  }
}

# DNS CAA records restricting certificate issuance to Cloudflare Universal SSL CAs
locals {
  caa_records = {
    letsencrypt_issue     = { tag = "issue", value = "letsencrypt.org" }
    letsencrypt_issuewild = { tag = "issuewild", value = "letsencrypt.org" }
    google_issue          = { tag = "issue", value = "pki.goog" }
    google_issuewild      = { tag = "issuewild", value = "pki.goog" }
    digicert_issue        = { tag = "issue", value = "digicert.com" }
    digicert_issuewild    = { tag = "issuewild", value = "digicert.com" }
    iodef                 = { tag = "iodef", value = "mailto:cameron@undo.is" }
  }
}

resource "cloudflare_record" "caa" {
  for_each = local.caa_records

  zone_id = data.cloudflare_zone.cityoftraitors.id
  name    = "@"
  type    = "CAA"

  data {
    flags = "0"
    tag   = each.value.tag
    value = each.value.value
  }
}

# asverify record to allow Azure to natively validate the custom domain for the Storage Account
resource "cloudflare_record" "asverify" {
  zone_id = data.cloudflare_zone.cityoftraitors.id
  name    = "asverify"
  content = "asverify.cityoftraitorscom.z20.web.core.windows.net"
  type    = "CNAME"
  proxied = false
}
