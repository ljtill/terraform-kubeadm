data "azurerm_client_config" "current" {}

#
# Resource Group
#

resource "azurerm_resource_group" "main" {
  name     = var.settings.resource_groups.identity
  location = var.settings.location

  tags = {
    "Service" = "Kubernetes"
  }
}

#
# Managed Identities
#

resource "azurerm_user_assigned_identity" "main_control" {
  name                = "mi-01"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}
resource "azurerm_user_assigned_identity" "main_worker" {
  name                = "mi-02"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}
