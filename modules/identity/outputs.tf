output "resource_ids" {
  value = {
    control_plane = azurerm_user_assigned_identity.main_control.id
    worker_plane  = azurerm_user_assigned_identity.main_worker.id
  }
}
