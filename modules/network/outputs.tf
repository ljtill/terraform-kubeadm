output "virtual_network_id" {
  value = azurerm_virtual_network.main.id
}

output "subnet_ids" {
  value = {
    control_plane = azurerm_subnet.main_control.id
    worker_plane  = azurerm_subnet.main_worker.id
  }
}

output "backend_ids" {
  value = {
    control_plane = azurerm_lb_backend_address_pool.main_control.id
  }
}
