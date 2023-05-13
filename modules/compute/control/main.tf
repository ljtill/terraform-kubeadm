#
# Network Interfaces
#

resource "azurerm_network_interface" "main_primary" {
  name                = "ni-01"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_ids.control_plane
    private_ip_address_allocation = "Static"
    private_ip_address            = "172.16.1.5"
  }
}
resource "azurerm_network_interface" "main_secondary" {
  name                = "ni-02"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_ids.control_plane
    private_ip_address_allocation = "Static"
    private_ip_address            = "172.16.1.6"
  }
}
resource "azurerm_network_interface" "main_tertiary" {
  name                = "ni-03"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_ids.control_plane
    private_ip_address_allocation = "Static"
    private_ip_address            = "172.16.1.7"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "main_primary" {
  network_interface_id    = azurerm_network_interface.main_primary.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = var.backend_ids.control_plane
}
resource "azurerm_network_interface_backend_address_pool_association" "main_secondary" {
  network_interface_id    = azurerm_network_interface.main_secondary.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = var.backend_ids.control_plane
}
resource "azurerm_network_interface_backend_address_pool_association" "main_tertiary" {
  network_interface_id    = azurerm_network_interface.main_tertiary.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = var.backend_ids.control_plane
}

#
# Virtual Machines
#

resource "azurerm_linux_virtual_machine" "main_primary" {
  name                = "vm-01"
  location            = var.location
  resource_group_name = var.resource_group_name

  size           = "Standard_D4s_v5"
  admin_username = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.main_primary.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file(".ssh/id_rsa.pub")
  }

  os_disk {
    name                 = "ds-01"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  zone = 1

  identity {
    type         = "UserAssigned"
    identity_ids = [var.resource_ids.control_plane]
  }
}
resource "azurerm_linux_virtual_machine" "main_secondary" {
  name                = "vm-02"
  location            = var.location
  resource_group_name = var.resource_group_name

  size           = "Standard_D4s_v5"
  admin_username = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.main_secondary.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file(".ssh/id_rsa.pub")
  }

  os_disk {
    name                 = "ds-02"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  zone = 2

  identity {
    type         = "UserAssigned"
    identity_ids = [var.resource_ids.control_plane]
  }
}
resource "azurerm_linux_virtual_machine" "main_tertiary" {
  name                = "vm-03"
  location            = var.location
  resource_group_name = var.resource_group_name

  size           = "Standard_D4s_v5"
  admin_username = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.main_tertiary.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file(".ssh/id_rsa.pub")
  }

  os_disk {
    name                 = "ds-03"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  zone = 3

  identity {
    type         = "UserAssigned"
    identity_ids = [var.resource_ids.control_plane]
  }
}

#
# Extensions
#

resource "azurerm_virtual_machine_extension" "main_primary" {
  name               = "Kubernetes"
  virtual_machine_id = azurerm_linux_virtual_machine.main_primary.id

  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "CustomScript"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    script = base64encode(templatefile("templates/kubernetes/install.tftpl",
      {
        node           = "init"
        token          = "${var.token_id}.${var.token_secret}"
        certificateKey = "${var.certificate_key}"
        endpoint       = "apiserver.${var.domains.root}"
    }))
  })
}
resource "azurerm_virtual_machine_extension" "main_secondary" {
  name               = "Kubernetes"
  virtual_machine_id = azurerm_linux_virtual_machine.main_secondary.id

  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "CustomScript"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    script = base64encode(templatefile("templates/kubernetes/install.tftpl",
      {
        node           = "control"
        token          = "${var.token_id}.${var.token_secret}"
        certificateKey = "${var.certificate_key}"
        endpoint       = "apiserver.${var.domains.root}"
    }))
  })

  depends_on = [
    azurerm_virtual_machine_extension.main_primary
  ]
}
resource "azurerm_virtual_machine_extension" "main_tertiary" {
  name               = "Kubernetes"
  virtual_machine_id = azurerm_linux_virtual_machine.main_tertiary.id

  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "CustomScript"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    script = base64encode(templatefile("templates/kubernetes/install.tftpl",
      {
        node           = "control"
        token          = "${var.token_id}.${var.token_secret}"
        certificateKey = "${var.certificate_key}"
        endpoint       = "apiserver.${var.domains.root}"
    }))
  })

  depends_on = [
    azurerm_virtual_machine_extension.main_primary,
    azurerm_virtual_machine_extension.main_secondary,
  ]
}
