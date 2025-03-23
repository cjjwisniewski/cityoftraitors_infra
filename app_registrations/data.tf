data "azurerm_resource_group" "cityoftraitors_rg" {
  name = "cityoftraitorscom"
}

data "azurerm_client_config" "current" {}