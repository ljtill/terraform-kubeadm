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

  resource_groups = local.resource_groups
  location        = local.location

  depends_on = [
    azurerm_resource_group.main
  ]
}

module "domain" {
  source = "./modules/domain"

  resource_groups    = local.resource_groups
  domains            = local.domains
  virtual_network_id = module.network.virtual_network_id

  depends_on = [
    azurerm_resource_group.main
  ]
}

module "identity" {
  source = "./modules/identity"

  resource_groups = local.resource_groups
  location        = local.location

  depends_on = [
    azurerm_resource_group.main
  ]
}

module "compute" {
  source = "./modules/compute"

  resource_groups = local.resource_groups
  location        = local.location

  domains = local.domains

  resource_ids = module.identity.resource_ids

  subnet_ids  = module.network.subnet_ids
  backend_ids = module.network.backend_ids

  depends_on = [
    azurerm_resource_group.main
  ]
}
