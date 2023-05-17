#
# Network Interfaces
#

resource "azurerm_network_interface" "main_primary" {
  name                = "ni-01"
  location            = var.settings.location
  resource_group_name = var.settings.resource_groups.control

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.settings.network.subnet_ids.control_plane
    private_ip_address_allocation = "Static"
    private_ip_address            = var.settings.compute.virtual_machines.primary.ip_address
  }
}
resource "azurerm_network_interface" "main_secondary" {
  name                = "ni-02"
  location            = var.settings.location
  resource_group_name = var.settings.resource_groups.control

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.settings.network.subnet_ids.control_plane
    private_ip_address_allocation = "Static"
    private_ip_address            = var.settings.compute.virtual_machines.secondary.ip_address
  }
}
resource "azurerm_network_interface" "main_tertiary" {
  name                = "ni-03"
  location            = var.settings.location
  resource_group_name = var.settings.resource_groups.control

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.settings.network.subnet_ids.control_plane
    private_ip_address_allocation = "Static"
    private_ip_address            = var.settings.compute.virtual_machines.tertiary.ip_address
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "main_primary" {
  network_interface_id    = azurerm_network_interface.main_primary.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = var.settings.network.backend_ids.control_plane
}
resource "azurerm_network_interface_backend_address_pool_association" "main_secondary" {
  network_interface_id    = azurerm_network_interface.main_secondary.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = var.settings.network.backend_ids.control_plane
}
resource "azurerm_network_interface_backend_address_pool_association" "main_tertiary" {
  network_interface_id    = azurerm_network_interface.main_tertiary.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = var.settings.network.backend_ids.control_plane
}

#
# Virtual Machines
#

resource "azurerm_linux_virtual_machine" "main_primary" {
  name                = "vm-01"
  location            = var.settings.location
  resource_group_name = var.settings.resource_groups.control

  size           = var.settings.compute.virtual_machines.size
  admin_username = var.settings.compute.credentials.username
  network_interface_ids = [
    azurerm_network_interface.main_primary.id,
  ]

  admin_ssh_key {
    username   = var.settings.compute.credentials.username
    public_key = file(var.settings.compute.credentials.ssh_key_path)
  }

  os_disk {
    name                 = "ds-01"
    caching              = "ReadWrite"
    storage_account_type = var.settings.compute.virtual_machines.disk_type
  }

  source_image_reference {
    publisher = var.settings.compute.image.publisher
    offer     = var.settings.compute.image.offer
    sku       = var.settings.compute.image.sku
    version   = var.settings.compute.image.version
  }

  zone = 1

  identity {
    type         = "UserAssigned"
    identity_ids = [var.settings.identity.user_ids.control_plane]
  }
}
resource "azurerm_linux_virtual_machine" "main_secondary" {
  name                = "vm-02"
  location            = var.settings.location
  resource_group_name = var.settings.resource_groups.control

  size           = var.settings.compute.virtual_machines.size
  admin_username = var.settings.compute.credentials.username
  network_interface_ids = [
    azurerm_network_interface.main_secondary.id,
  ]

  admin_ssh_key {
    username   = var.settings.compute.credentials.username
    public_key = file(var.settings.compute.credentials.ssh_key_path)
  }

  os_disk {
    name                 = "ds-02"
    caching              = "ReadWrite"
    storage_account_type = var.settings.compute.virtual_machines.disk_type
  }

  source_image_reference {
    publisher = var.settings.compute.image.publisher
    offer     = var.settings.compute.image.offer
    sku       = var.settings.compute.image.sku
    version   = var.settings.compute.image.version
  }

  zone = 2

  identity {
    type         = "UserAssigned"
    identity_ids = [var.settings.identity.user_ids.control_plane]
  }
}
resource "azurerm_linux_virtual_machine" "main_tertiary" {
  name                = "vm-03"
  location            = var.settings.location
  resource_group_name = var.settings.resource_groups.control

  size           = var.settings.compute.virtual_machines.size
  admin_username = var.settings.compute.credentials.username
  network_interface_ids = [
    azurerm_network_interface.main_tertiary.id,
  ]

  admin_ssh_key {
    username   = var.settings.compute.credentials.username
    public_key = file(var.settings.compute.credentials.ssh_key_path)
  }

  os_disk {
    name                 = "ds-03"
    caching              = "ReadWrite"
    storage_account_type = var.settings.compute.virtual_machines.disk_type
  }

  source_image_reference {
    publisher = var.settings.compute.image.publisher
    offer     = var.settings.compute.image.offer
    sku       = var.settings.compute.image.sku
    version   = var.settings.compute.image.version
  }

  zone = 3

  identity {
    type         = "UserAssigned"
    identity_ids = [var.settings.identity.user_ids.control_plane]
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
        token          = "${var.settings.cluster.token_id}.${var.settings.cluster.token_secret}"
        certificateKey = "${var.settings.cluster.certificate_key}"
        endpoint       = "apiserver.${var.settings.domain.dns_zone}"
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
        token          = "${var.settings.cluster.token_id}.${var.settings.cluster.token_secret}"
        certificateKey = "${var.settings.cluster.certificate_key}"
        endpoint       = "apiserver.${var.settings.domain.dns_zone}"
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
        token          = "${var.settings.cluster.token_id}.${var.settings.cluster.token_secret}"
        certificateKey = "${var.settings.cluster.certificate_key}"
        endpoint       = "apiserver.${var.settings.domain.dns_zone}"
    }))
  })

  depends_on = [
    azurerm_virtual_machine_extension.main_primary,
    azurerm_virtual_machine_extension.main_secondary,
  ]
}
