

// Resource Group

resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = local.location

  tags = {
    "Service" = "Kubernetes"
  }
}

// Modules

module "network" {
  source = "./modules/network"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  resource_names    = local.resource_names
  resource_prefixes = local.resource_prefixes
}

module "compute" {
  source = "./modules/compute"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  resource_prefixes = local.resource_prefixes

  node_count = {
    control_plane = 2
    data_plane    = 3
  }

  subnet_ids = module.network.subnet_ids
}
