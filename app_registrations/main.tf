resource "azuread_application" "cityoftraitors_github" {
  display_name = "cityoftraitors-com-github-actions"
  owners       = [data.azurerm_client_config.current.object_id]
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }
  }
  web {
    homepage_url = "https://www.cityoftraitors.com"
  }
}

resource "azuread_service_principal" "cityoftraitors_github" {
  client_id                    = azuread_application.cityoftraitors_github.client_id
  app_role_assignment_required = false
  owners                       = [data.azurerm_client_config.current.object_id]
}

resource "azuread_application_federated_identity_credential" "cityoftraitors_github" {
  application_id = azuread_application.cityoftraitors_github.id
  display_name   = "github-actions-deploy"
  description    = "Deploy from GitHub Actions"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:cjjwisniewski/cityoftraitors.com:ref:refs/heads/main"
}

resource "azurerm_role_assignment" "github_deploy_storage" {
  scope                = data.azurerm_storage_account.cityoftraitors.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.cityoftraitors_github.object_id
}

resource "azurerm_role_assignment" "github_deploy_cdn" {
  scope                = data.azurerm_cdn_profile.cityoftraitors.id
  role_definition_name = "CDN Endpoint Contributor"
  principal_id         = azuread_service_principal.cityoftraitors_github.object_id
}