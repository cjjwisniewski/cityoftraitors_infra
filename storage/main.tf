resource "azurerm_storage_account" "cityoftraitors" {
  name                            = "cityoftraitorscom"
  resource_group_name             = data.azurerm_resource_group.cityoftraitors_rg.name
  location                        = data.azurerm_resource_group.cityoftraitors_rg.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
  https_traffic_only_enabled      = true

  custom_domain {
    name          = "cityoftraitors.com"
    use_subdomain = true
  }
}

resource "azurerm_storage_account_static_website" "cityoftraitors" {
  storage_account_id = azurerm_storage_account.cityoftraitors.id
  index_document     = "index.html"
  error_404_document = "index.html"
}


# Can't actually create these in TF because of the $ in the name, not sure what to do about it
#resource "azurerm_storage_container" "cityoftraitors_logs" {
#  name                  = "$logs"
#  storage_account_id    = azurerm_storage_account.cityoftraitors.id
#  container_access_type = "private"
#}
#
#resource "azurerm_storage_container" "cityoftraitors_web" {
#  name                  = "$web"
#  storage_account_id    = azurerm_storage_account.cityoftraitors.id
#  container_access_type = "private"
#}