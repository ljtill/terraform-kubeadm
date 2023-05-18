locals {
  location = "uksouth"
  resource_groups = {
    network  = "kubernetes-network-${local.location}"
    identity = "kubernetes-identity-${local.location}"
    bastion  = "kubernetes-bastion-${local.location}"
    control  = "kubernetes-control-${local.location}"
    worker   = "kubernetes-worker-${local.location}"
  }
}
