#
# Resources
#

resource "random_string" "token_id" {
  length  = 6
  special = false
  upper   = false
}

resource "random_string" "token_secret" {
  length  = 16
  special = false
  upper   = false
}

resource "random_id" "certificate_key" {
  byte_length = 32
}

#
# Modules
#

module "control" {
  source = "./control"

  settings = {
    location        = var.settings.location
    resource_groups = var.settings.resource_groups
    cluster = {
      token_id        = random_string.token_id.result
      token_secret    = random_string.token_secret.result
      certificate_key = random_id.certificate_key.hex
    }
    compute = var.settings.compute
    domain  = var.settings.domain
    network = var.settings.network
  }
}

module "worker" {
  source = "./worker"

  settings = {
    location        = var.settings.location
    resource_groups = var.settings.resource_groups
    cluster = {
      token_id        = random_string.token_id.result
      token_secret    = random_string.token_secret.result
      certificate_key = random_id.certificate_key.hex
    }
    compute = var.settings.compute
    domain  = var.settings.domain
    network = var.settings.network
  }

  depends_on = [
    module.control
  ]
}
