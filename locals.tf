locals {
  location = "uksouth"
  resource_groups = {
    network  = "kubernetes-network-${local.location}"
    domain   = "kubernetes-domain-${local.location}"
    identity = "kubernetes-identity-${local.location}"
    control  = "kubernetes-control-${local.location}"
    worker   = "kubernetes-worker-${local.location}"
  }
}
