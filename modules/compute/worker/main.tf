#
# Scale Set
#

resource "azurerm_orchestrated_virtual_machine_scale_set" "main" {
  name                = "ss-01"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name  = "Standard_D8s_v5"
  instances = 3

  os_profile {
    linux_configuration {
      computer_name_prefix = "vm-ss-"
      admin_username       = "adminuser"
      admin_ssh_key {
        username   = "adminuser"
        public_key = file(".ssh/id_rsa.pub")
      }
    }
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  network_interface {
    name    = "ni"
    primary = true

    ip_configuration {
      name      = "ipconfig1"
      primary   = true
      subnet_id = var.subnet_ids.worker_plane
    }
  }

  extension {
    name                               = "Kubernetes"
    publisher                          = "Microsoft.Azure.Extensions"
    type                               = "CustomScript"
    type_handler_version               = "2.0"
    auto_upgrade_minor_version_enabled = true

    settings = jsonencode({
      script = base64encode(templatefile("templates/kubernetes/install.tftpl",
        {
          node           = "worker"
          token          = "${var.token_id}.${var.token_secret}"
          certificateKey = "${var.certificate_key}"
          endpoint       = "apiserver.${var.domains.root}"
      }))
    })
  }

  platform_fault_domain_count = 1

  identity {
    type         = "UserAssigned"
    identity_ids = [var.resource_ids.worker_plane]
  }
}

#
# Autoscale
#

resource "azurerm_monitor_autoscale_setting" "main" {
  name                = "default"
  location            = var.location
  resource_group_name = var.resource_group_name
  target_resource_id  = azurerm_orchestrated_virtual_machine_scale_set.main.id

  profile {
    name = "Profile"

    capacity {
      default = 5
      minimum = 3
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_resource_id = azurerm_orchestrated_virtual_machine_scale_set.main.id
        metric_namespace   = "Microsoft.Compute/virtualMachineScaleSets"
        metric_name        = "Percentage CPU"
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_resource_id = azurerm_orchestrated_virtual_machine_scale_set.main.id
        metric_namespace   = "Microsoft.Compute/virtualMachineScaleSets"
        metric_name        = "Percentage CPU"
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}
