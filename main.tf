#
# Resource Group
#

resource "azurerm_resource_group" "main" {
  name     = each.value
  location = local.location

  tags = {
    "Service" = "Kubernetes"
  }

  for_each = local.resource_groups
}

#
# Modules
#

module "network" {
  source = "./modules/network"

  settings = {
    location        = local.location,
    resource_groups = local.resource_groups,
    network         = local.network
  }

  depends_on = [
    azurerm_resource_group.main
  ]
}

module "domain" {
  source = "./modules/domain"

  settings = {
    resource_groups = local.resource_groups,
    domain          = local.domain
    network = {
      virtual_network_id = module.network.virtual_network_id
    }
  }

  depends_on = [
    azurerm_resource_group.main
  ]
}

module "compute" {
  source = "./modules/compute"

  settings = {
    location        = local.location,
    resource_groups = local.resource_groups,
    compute         = local.compute
    domain          = local.domain
    network = {
      subnet_ids  = module.network.subnet_ids
      backend_ids = module.network.backend_ids
    }
  }

  depends_on = [
    azurerm_resource_group.main
  ]
}
