terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      # Set minimum known working version
      version = ">= 3.100.0"
    }
  }

  required_version = ">= 1.3.0"
}

provider "azurerm" {
  features {}
}
