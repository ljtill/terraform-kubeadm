#
# Virtual Machines
#

# Control Plane

resource "azurerm_network_interface" "main_control" {
  name                = "${var.resource_prefixes.network_interface}-CP-${format("%02s", count.index)}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_ids.control_plane
    private_ip_address_allocation = "Dynamic"
  }

  count = 2
}

resource "azurerm_linux_virtual_machine" "main_control" {
  name                = "${var.resource_prefixes.virtual_machine}-CP-${format("%02s", count.index)}"
  location            = var.location
  resource_group_name = var.resource_group_name

  size           = "Standard_D4s_v5"
  admin_username = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.main_control[count.index].id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file(".ssh/id_rsa.pub")
  }

  os_disk {
    name                 = "${var.resource_prefixes.os_disk}-CP-${format("%02s", count.index)}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    "Type" = "ControlPlane"
  }

  count = var.node_count.control_plane
}

# Data Plane

resource "azurerm_network_interface" "main_data" {
  name                = "${var.resource_prefixes.network_interface}-DP-${format("%02s", count.index)}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_ids.data_plane
    private_ip_address_allocation = "Dynamic"
  }

  count = 3
}

resource "azurerm_linux_virtual_machine" "main_data" {
  name                = "${var.resource_prefixes.virtual_machine}-DP-${format("%02s", count.index)}"
  location            = var.location
  resource_group_name = var.resource_group_name

  size           = "Standard_D8s_v5"
  admin_username = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.main_data[count.index].id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file(".ssh/id_rsa.pub")
  }

  os_disk {
    name                 = "${var.resource_prefixes.os_disk}-DP-${format("%02s", count.index)}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    "Type" = "DataPlane"
  }

  count = var.node_count.data_plane
}
