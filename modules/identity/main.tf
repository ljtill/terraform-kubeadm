data "azurerm_client_config" "current" {}

#
# Managed Identity
#

resource "azurerm_user_assigned_identity" "main_control" {
  name                = "mi-01"
  location            = var.location
  resource_group_name = var.resource_groups.identity
}
resource "azurerm_user_assigned_identity" "main_worker" {
  name                = "mi-02"
  location            = var.location
  resource_group_name = var.resource_groups.identity
}

#
# Role Assignments
#

resource "azurerm_role_assignment" "main_control" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_groups.control}"
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.main_control.principal_id
}
resource "azurerm_role_assignment" "main_control_worker" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_groups.worker}"
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.main_control.principal_id
}
resource "azurerm_role_assignment" "main_control_network" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_groups.network}"
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.main_control.principal_id
}

resource "azurerm_role_assignment" "main_worker" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_groups.worker}"
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.main_worker.principal_id
}
