terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.61.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">=3.3.0"
    }
  }
}
