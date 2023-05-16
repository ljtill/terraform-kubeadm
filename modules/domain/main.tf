#
# Private DNS
#

resource "azurerm_private_dns_zone" "main" {
  name                = var.settings.domain.dns_zone
  resource_group_name = var.settings.resource_groups.domain
}

resource "azurerm_private_dns_a_record" "main" {
  name                = "apiserver"
  zone_name           = azurerm_private_dns_zone.main.name
  resource_group_name = var.settings.resource_groups.domain

  ttl     = 300
  records = ["172.16.1.4"]
}

resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  name                = "default"
  resource_group_name = var.settings.resource_groups.domain

  private_dns_zone_name = azurerm_private_dns_zone.main.name
  virtual_network_id    = var.settings.network.virtual_network_id
}
