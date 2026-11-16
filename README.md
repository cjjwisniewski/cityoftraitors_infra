# cityoftraitors_infra — Azure & Cloudflare Infrastructure

Terraform configuration for [`cityoftraitors.com`](https://cityoftraitors.com) on Azure Blob Storage (`$web`), fronted by Cloudflare DNS/CDN, with GitHub Actions OIDC deployment.

> **Note:** Infrastructure for **Seeker** (`seeker`) is managed separately from `cityoftraitors_infra`.

## Architecture & Module Layout

This repository is organized into **5 independent Terraform root modules**, each storing its own state in Azure Storage account `cityoftraitorsinfra` (`cityoftraitors-infra-container` in resource group `cityoftraitorscom`):

| Order | Directory | State Key | Purpose |
|---|---|---|---|
| 1 | `resource_group/` | `cityoftraitors-infra/resource_group.tfstate` | Azure Resource Group `cityoftraitorscom` (`East US 2`) |
| 2 | `backend/` | `cityoftraitors-infra/backend.tfstate` | Terraform state Storage Account `cityoftraitorsinfra` & container `cityoftraitors-infra-container` |
| 3 | `storage/` | `cityoftraitors-infra/storage.tfstate` | Static site Storage Account `cityoftraitorscom` (`Standard_LRS`), static website (`index.html` / `index.html`), custom domain `cityoftraitors.com` |
| 4 | `cloudflare/` | `cityoftraitors-infra/cloudflare.tfstate` | Cloudflare `@` and `www` CNAMEs (`proxied = true`), unproxied `asverify` CNAME, `www` -> apex `301` Page Rule, Zone SSL/Brotli settings |
| 5 | `app_registrations/` | `cityoftraitors-infra/app_registrations.tfstate` | Azure AD App & SP `cityoftraitors-com-github-actions` with federated credential for `repo:cjjwisniewski/cityoftraitors.com:ref:refs/heads/main` and `Storage Blob Data Contributor` |

## CI/CD Workflow (`.github/workflows/deploy.yml`)

- **Plan-only on Push/PR**: Pushes and pull requests to `main` run `terraform init`, `terraform validate`, and `terraform plan` across all 5 modules in order; auto-apply is disabled.
- **Manual Apply (`workflow_dispatch`)**: Trigger `workflow_dispatch` with `apply=true`, optionally selecting a single `module` (`all` or one of the 5 directories) and `untaint_address` (when targeting a single module).
- **Destructive-Plan Guard**: Inspects `terraform show -json tfplan` for each module and aborts if any `delete` / replacement action is planned (`DESTROY_COUNT > 0`) to protect stateful resources.
- **Required GitHub Variables / Secrets**:
  - `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` (vars or secrets; `AZURE_SUBSCRIPTION_ID` is also passed as `TF_VAR_subscription_id`)
  - `CLOUDFLARE_API_TOKEN` (secret; required for `all` or `cloudflare`)

## Local Usage

Every module requires `var.subscription_id`:

```bash
az login
export TF_VAR_subscription_id="<your-azure-subscription-id>"
export CLOUDFLARE_API_TOKEN="<your-cloudflare-api-token>" # required for cloudflare/

cd storage
terraform init
terraform plan
terraform apply
```

## License

See [LICENSE](LICENSE) for details.
