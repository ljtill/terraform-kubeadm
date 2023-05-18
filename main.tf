#
# Modules
#

module "compute" {
  source = "./modules/compute"

  settings = {
    location        = local.location,
    resource_groups = local.resource_groups,
    compute         = local.compute
    network = {
      dns_zone    = local.network.dns_zone
      subnet_ids  = module.network.subnet_ids
      backend_ids = module.network.backend_ids
    }
    identity = {
      principal_ids = module.identity.principal_ids
      user_ids      = module.identity.user_ids
    }
  }
}

module "identity" {
  source = "./modules/identity"

  settings = {
    resource_groups = local.resource_groups,
    location        = local.location,
  }
}

module "network" {
  source = "./modules/network"

  settings = {
    location        = local.location,
    resource_groups = local.resource_groups,
    network         = local.network
    identity = {
      principal_ids = module.identity.principal_ids
      user_ids      = module.identity.user_ids
    }
  }
}
