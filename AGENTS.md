# cityoftraitors_infra — Agent Guidelines & Repository Specifics

This repository contains the Terraform configuration for **`cityoftraitors.com`** (`cjjwisniewski/cityoftraitors_infra`).

> **Scope Note:** Infrastructure for **Seeker** (`seeker`) is managed separately from `cityoftraitors_infra`.

## 1. Git, CI/CD & Documentation Continuity
- **Commit & Push**: Use [Conventional Commits](https://www.conventionalcommits.org/) (`feat(scope):`, `fix(scope):`, `chore(scope):`, `docs(scope):`) and push to `origin/main`.
- **Keep BookStack up to date**: Whenever Azure resources, Cloudflare DNS/rules, or OIDC/CI rules change, update the **`City of Traitors`** book in BookStack (`HomeLab` shelf, via `bookstack-mcp` at `http://127.0.0.1:8002/mcp`).

## 2. Multi-Root Terraform Layout & Safety Guards
- **5 Independent Root Modules** (applied in dependency order):
  1. `resource_group/` (`cityoftraitors-infra/resource_group.tfstate`)
  2. `backend/` (`cityoftraitors-infra/backend.tfstate`)
  3. `storage/` (`cityoftraitors-infra/storage.tfstate`)
  4. `cloudflare/` (`cityoftraitors-infra/cloudflare.tfstate`)
  5. `app_registrations/` (`cityoftraitors-infra/app_registrations.tfstate`)
- **Remote State**: All 5 modules store state in Azure Storage account `cityoftraitorsinfra`, container `cityoftraitors-infra-container`, resource group `cityoftraitorscom`.
- **Required Variable**: Every module requires `var.subscription_id` (`export TF_VAR_subscription_id="..."` locally; wired from `AZURE_SUBSCRIPTION_ID` in CI).
- **No Auto-Apply on Push**: `.github/workflows/deploy.yml` runs `init`, `validate`, and `plan` across all 5 modules on `push` / `pull_request` to `main`.
- **Manual Apply & Destructive-Plan Guard**: Trigger `workflow_dispatch` with `apply=true` (and optional `module` selector / `untaint_address`). CI aborts if `DESTROY_COUNT > 0` in any planned module to protect stateful resources.
- **Never Commit Plan Files**: `*tfplan*` is gitignored; do not commit binary `tfplan` files.

## 3. Infrastructure Coupling & Invariants
- **Azure Storage & Static Website (`storage/main.tf`)**:
  - `cityoftraitorscom` (`Standard_LRS`, `allow_nested_items_to_be_public = false`, `https_traffic_only_enabled = true`) binds custom domain `cityoftraitors.com` (`use_subdomain = true`).
  - `azurerm_storage_account_static_website` sets `index_document = "index.html"` and `error_404_document = "index.html"`.
- **Cloudflare (`cloudflare/main.tf`)**:
  - `@` and `www` CNAMEs point to `cityoftraitorscom.z20.web.core.windows.net` (`proxied = true`).
  - `asverify` CNAME -> `asverify.cityoftraitorscom.z20.web.core.windows.net` **must remain `proxied = false`** for Azure domain validation.
  - `www.cityoftraitors.com/*` redirects `301` to `https://cityoftraitors.com/$1`.
  - Zone SSL is `full` with `always_use_https = "on"`, `automatic_https_rewrites = "on"`, `brotli = "on"`, `email_obfuscation = "off"`, and `rocket_loader = "off"`.
  - Response security headers (`CSP`, `HSTS`, `X-Frame-Options`, `X-Content-Type-Options`, `Referrer-Policy`, `Permissions-Policy`) for `cityoftraitors.com` are managed alongside `seeker.cityoftraitors.com` inside `seeker_infra/dns/main.tf` (`cloudflare_ruleset.security_headers`), because Cloudflare allows only one `http_response_headers_transform` ruleset per zone.
- **GitHub Actions OIDC (`app_registrations/main.tf`)**:
  - `cityoftraitors-com-github-actions` App/SP has federated identity scoped strictly to `repo:cjjwisniewski/cityoftraitors.com:ref:refs/heads/main` and `Storage Blob Data Contributor` on `cityoftraitorscom`.
  - `azuread_application` and `azuread_service_principal` use `lifecycle { ignore_changes = [owners] }` to prevent drift when Terraform runs under a CI Service Principal.
