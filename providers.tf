terraform {
  required_version = ">= 1.5.0"
  required_providers {
    random = {
      source = "hashicorp/random"
    }
    http = {
      source = "hashicorp/http"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }

  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    app_configuration {
      purge_soft_delete_on_destroy = true
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}
