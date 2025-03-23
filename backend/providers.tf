terraform {
  backend "azurerm" {
    resource_group_name  = "cityoftraitorscom"
    storage_account_name = "cityoftraitorsinfra"
    container_name       = "cityoftraitors-infra-container"
    key                  = "cityoftraitors-infra/backend.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}