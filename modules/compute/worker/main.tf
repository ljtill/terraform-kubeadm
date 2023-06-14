data "azurerm_client_config" "current" {}

#
# Resource Group
#

resource "azurerm_resource_group" "main" {
  name     = var.settings.resource_groups.worker
  location = var.settings.location

  tags = {
    "Service" = "Kubernetes"
  }
}

resource "azurerm_role_assignment" "main_control" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${azurerm_resource_group.main.name}"
  role_definition_name = "Contributor"
  principal_id         = var.settings.identity.principal_ids.control
}
resource "azurerm_role_assignment" "main_worker" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${azurerm_resource_group.main.name}"
  role_definition_name = "Contributor"
  principal_id         = var.settings.identity.principal_ids.worker
}

#
# Scale Set
#

resource "azurerm_orchestrated_virtual_machine_scale_set" "main" {
  name                = "ss-01"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  sku_name  = var.settings.compute.virtual_machine_scale_sets.size
  instances = var.settings.compute.virtual_machine_scale_sets.instances.minimum

  os_profile {
    linux_configuration {
      computer_name_prefix = "vm-ss-"
      admin_username       = var.settings.compute.credentials.username
      admin_ssh_key {
        username   = var.settings.compute.credentials.username
        public_key = file(var.settings.compute.credentials.ssh_key_path)
      }
    }
  }

  source_image_reference {
    publisher = var.settings.compute.image.publisher
    offer     = var.settings.compute.image.offer
    sku       = var.settings.compute.image.sku
    version   = var.settings.compute.image.version
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.settings.compute.virtual_machine_scale_sets.disk_type
  }

  network_interface {
    name    = "ni"
    primary = true

    ip_configuration {
      name      = "ipconfig1"
      primary   = true
      subnet_id = var.settings.network.subnet_ids.worker
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
          token          = "${var.settings.cluster.token_id}.${var.settings.cluster.token_secret}"
          certificateKey = "${var.settings.cluster.certificate_key}"
          endpoint       = "apiserver.${var.settings.network.dns_zone.name}"
      }))
    })
  }

  platform_fault_domain_count = 1

  identity {
    type         = "UserAssigned"
    identity_ids = [var.settings.identity.user_ids.worker]
  }
}

#
# Autoscale
#

resource "azurerm_monitor_autoscale_setting" "main" {
  name                = "default"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  target_resource_id  = azurerm_orchestrated_virtual_machine_scale_set.main.id

  profile {
    name = "Profile"

    capacity {
      default = var.settings.compute.virtual_machine_scale_sets.instances.default
      minimum = var.settings.compute.virtual_machine_scale_sets.instances.minimum
      maximum = var.settings.compute.virtual_machine_scale_sets.instances.maximum
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
