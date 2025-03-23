resource "azurerm_storage_account" "cityoftraitors_infra_storage" {
  name                     = "cityoftraitorsinfra"
  resource_group_name      = data.azurerm_resource_group.cityoftraitors_rg.name
  location                 = data.azurerm_resource_group.cityoftraitors_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "cityoftraitors_infra_container" {
  name                  = "cityoftraitors-infra-container"
  storage_account_id    = azurerm_storage_account.cityoftraitors_infra_storage.id
  container_access_type = "private"
}