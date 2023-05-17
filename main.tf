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

module "identity" {
  source = "./modules/identity"

  settings = {
    resource_groups = local.resource_groups,
    location        = local.location,
  }

  depends_on = [
    azurerm_resource_group.main
  ]
}

module "vault" {
  source = "./modules/vault"

  settings = {
    resource_groups = local.resource_groups,
    location        = local.location,
    identity        = {
      principal_ids = module.identity.principal_ids
    }
  }

  depends_on = [
    azurerm_resource_group.main
  ]
}

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
    network = {
      subnet_ids  = module.network.subnet_ids
      backend_ids = module.network.backend_ids
    }
    identity = {
      user_ids = module.identity.user_ids
    }
    domain = local.domain
  }

  depends_on = [
    azurerm_resource_group.main
  ]
}
