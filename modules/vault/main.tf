data "azurerm_client_config" "current" {}

#
# Settings
#

resource "random_string" "name" {
  length  = 5
  special = false
  upper   = false
}

#
# Key Vault
#

resource "azurerm_key_vault" "main" {
  name                = random_string.name.result
  location            = var.settings.location
  resource_group_name = var.settings.resource_groups.vault

  sku_name                 = "standard"
  purge_protection_enabled = false
  tenant_id                = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_role_assignment" "main" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}
resource "azurerm_role_assignment" "main_worker" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.settings.identity.principal_ids.control_plane
}

#
# App Configuration
#

resource "azurerm_app_configuration" "main" {
  name                = random_string.name.result
  location            = var.settings.location
  resource_group_name = var.settings.resource_groups.vault

  sku                      = "standard"
  purge_protection_enabled = false
}
