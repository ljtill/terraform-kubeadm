output "virtual_network_id" {
  value = azurerm_virtual_network.main.id
}

output "subnet_ids" {
  value = {
    control = azurerm_subnet.main_control.id
    worker  = azurerm_subnet.main_worker.id
    bastion = azurerm_subnet.main_bastion.id
  }
}

output "backend_ids" {
  value = {
    control = azurerm_lb_backend_address_pool.main_control.id
    worker  = ""
  }
}
