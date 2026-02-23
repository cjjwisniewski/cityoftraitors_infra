data "azurerm_resource_group" "cityoftraitors_rg" {
  name = "cityoftraitorscom"
}

data "azurerm_client_config" "current" {}

data "azurerm_storage_account" "cityoftraitors" {
  name                = "cityoftraitorscom"
  resource_group_name = data.azurerm_resource_group.cityoftraitors_rg.name
}

data "azurerm_cdn_profile" "cityoftraitors" {
  name                = "cityoftraitors-com-cdn-1"
  resource_group_name = data.azurerm_resource_group.cityoftraitors_rg.name
}