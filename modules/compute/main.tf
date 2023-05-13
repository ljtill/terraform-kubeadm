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

  resource_group_name = var.resource_groups.control
  location            = var.location

  token_secret    = random_string.token_secret.result
  token_id        = random_string.token_id.result
  certificate_key = random_id.certificate_key.hex

  domains = var.domains

  resource_ids = var.resource_ids

  subnet_ids  = var.subnet_ids
  backend_ids = var.backend_ids
}

module "worker" {
  source = "./worker"

  resource_group_name = var.resource_groups.worker
  location            = var.location

  token_secret    = random_string.token_secret.result
  token_id        = random_string.token_id.result
  certificate_key = random_id.certificate_key.hex

  domains = var.domains

  resource_ids = var.resource_ids

  subnet_ids = var.subnet_ids

  depends_on = [
    module.control
  ]
}
