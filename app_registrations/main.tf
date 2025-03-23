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

resource "azuread_application_password" "cityoftraitors_github" {
  application_id    = azuread_application.cityoftraitors_github.id
  display_name      = "Github Actions"
  end_date_relative = "8760h"
}