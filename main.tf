data "azurerm_client_config" "current" {}

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

#
# Manifests
#

resource "local_file" "main" {
  filename = "./manifests/kubernetes/secret.yaml"
  content  = <<-EOT
    ---
    apiVersion: v1
    kind: Secret
    metadata:
      name: cloud-config
      namespace: kube-system
    type: Opaque
    stringData:
      cloud-config: |-
        {
          "cloud": "AzurePublicCloud",
          "tenantId": "${data.azurerm_client_config.current.tenant_id}",
          "subscriptionId": "${data.azurerm_client_config.current.subscription_id}",
          "resourceGroup": "${local.resource_groups.worker}",
          "location": "uksouth",
          "vnetName": "vn-01",
          "vnetResourceGroup": "${local.resource_groups.network}",
          "subnetName": "ServiceSubnet",
          "securityGroupName": "sg-01",
          "securityGroupResourceGroup": "${local.resource_groups.network}",
          "vmType": "vmssflex",
          "primaryScaleSetName": "ss-01",
          "loadBalancerSku": "standard",
          "loadBalancerName": "kubernetes",
          "loadBalancerResourceGroup": "${local.resource_groups.network}",
          "useInstanceMetadata": true,
          "useManagedIdentityExtension": true,
          "userAssignedIdentityID": "${module.identity.principal_ids.control_plane}"
        }
  EOT
}
