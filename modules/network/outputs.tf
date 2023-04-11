output "subnet_ids" {
  value = {
    control_plane = azurerm_subnet.main_control.id
    data_plane    = azurerm_subnet.main_data.id
  }
}
