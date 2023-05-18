#
# Resource Group
#

resource "azurerm_resource_group" "main" {
  name     = var.settings.resource_groups.bastion
  location = var.settings.location

  tags = {
    "Service" = "Kubernetes"
  }
}

#
# Network Interface
#

resource "azurerm_network_interface" "main" {
  name                = "ni-01"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.settings.network.subnet_ids.service_plane
    private_ip_address_allocation = "Static"
    private_ip_address            = var.settings.compute.bastion.ip_address
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

#
# Public IP
#

resource "azurerm_public_ip" "main" {
  name                = "ip-01"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  allocation_method = "Static"
  sku               = "Standard"
}

#
# Virtual Machine
#

resource "azurerm_linux_virtual_machine" "main" {
  name                = "vm-01"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  size           = var.settings.compute.bastion.size
  admin_username = var.settings.compute.credentials.username
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  admin_ssh_key {
    username   = var.settings.compute.credentials.username
    public_key = file(var.settings.compute.credentials.ssh_key_path)
  }

  os_disk {
    name                 = "ds-01"
    caching              = "ReadWrite"
    storage_account_type = var.settings.compute.bastion.disk_type
  }

  source_image_reference {
    publisher = var.settings.compute.image.publisher
    offer     = var.settings.compute.image.offer
    sku       = var.settings.compute.image.sku
    version   = var.settings.compute.image.version
  }
}
