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
    security_level           = "medium"
    ssl                      = "full"
  }
}

# Redirect www to root domain
resource "cloudflare_page_rule" "www_to_root" {
  zone_id = data.cloudflare_zone.cityoftraitors.id
  target  = "www.cityoftraitors.com/*"
  status  = "active"

  actions {
    forwarding_url {
      url         = "https://cityoftraitors.com/$1"
      status_code = 301
    }
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
