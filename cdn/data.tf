data "azurerm_resource_group" "cityoftraitors_rg" {
  name = "cityoftraitorscom"
}

data "azurerm_client_config" "current" {}

data "azurerm_storage_account" "cityoftraitors" {
  name                = "cityoftraitorscom"
  resource_group_name = data.azurerm_resource_group.cityoftraitors_rg.name
}