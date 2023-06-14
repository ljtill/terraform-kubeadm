output "principal_ids" {
  value = {
    control = azurerm_user_assigned_identity.main_control.principal_id
    worker  = azurerm_user_assigned_identity.main_worker.principal_id
  }
}

output "user_ids" {
  value = {
    control = azurerm_user_assigned_identity.main_control.id
    worker  = azurerm_user_assigned_identity.main_worker.id
  }
}
