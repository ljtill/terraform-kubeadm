data "azurerm_client_config" "current" {}

#
# Resource Group
#

resource "azurerm_resource_group" "main" {
  name     = var.settings.resource_groups.network
  location = var.settings.location

  tags = {
    "Service" = "Kubernetes"
  }
}

resource "azurerm_role_assignment" "main" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${azurerm_resource_group.main.name}"
  role_definition_name = "Contributor"
  principal_id         = var.settings.identity.principal_ids.control
}

#
# Private DNS
#

resource "azurerm_private_dns_zone" "main" {
  name                = var.settings.network.dns_zone.name
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_a_record" "main" {
  name                = "apiserver"
  zone_name           = azurerm_private_dns_zone.main.name
  resource_group_name = azurerm_resource_group.main.name

  ttl     = 300
  records = ["172.16.1.4"]
}

resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  name                = "default"
  resource_group_name = azurerm_resource_group.main.name

  private_dns_zone_name = azurerm_private_dns_zone.main.name
  virtual_network_id    = azurerm_virtual_network.main.id
}

#
# Virtual Network
#

resource "azurerm_virtual_network" "main" {
  name                = "vn-01"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  address_space = [var.settings.network.virtual_network.address_space]
}

resource "azurerm_subnet" "main_control" {
  name                = "ControlSubnet"
  resource_group_name = azurerm_resource_group.main.name

  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.settings.network.virtual_network.subnets.control.address_prefix]
}
resource "azurerm_subnet" "main_worker" {
  name                = "WorkerSubnet"
  resource_group_name = azurerm_resource_group.main.name

  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.settings.network.virtual_network.subnets.worker.address_prefix]
}
resource "azurerm_subnet" "main_service" {
  name                = "ServiceSubnet"
  resource_group_name = azurerm_resource_group.main.name

  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.settings.network.virtual_network.subnets.service.address_prefix]
}
resource "azurerm_subnet" "main_bastion" {
  name                = "BastionSubnet"
  resource_group_name = azurerm_resource_group.main.name

  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.settings.network.virtual_network.subnets.bastion.address_prefix]
}

#
# Security Group
#

resource "azurerm_network_security_group" "main_control" {
  name                = "sg-01"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}
resource "azurerm_network_security_group" "main_worker" {
  name                = "sg-02"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}
resource "azurerm_network_security_group" "main_service" {
  name                = "sg-03"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

data "http" "main" {
  url = "http://whatismyip.akamai.com/"
}

resource "azurerm_network_security_group" "main_bastion" {
  name                = "sg-04"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule = [
    {
      name                                       = "AllowMyIpAddressSSHInbound"
      description                                = "Remote Access"
      access                                     = "Allow"
      direction                                  = "Inbound"
      priority                                   = "100"
      protocol                                   = "Tcp"
      source_port_range                          = "*"
      source_port_ranges                         = []
      source_address_prefix                      = "${data.http.main.response_body}/32"
      source_address_prefixes                    = []
      source_application_security_group_ids      = []
      destination_address_prefix                 = "${var.settings.network.virtual_network.subnets.bastion.address_prefix}"
      destination_address_prefixes               = []
      destination_application_security_group_ids = []
      destination_port_range                     = "22"
      destination_port_ranges                    = []
    }
  ]
}

resource "azurerm_subnet_network_security_group_association" "main_control" {
  subnet_id                 = azurerm_subnet.main_control.id
  network_security_group_id = azurerm_network_security_group.main_control.id
}
resource "azurerm_subnet_network_security_group_association" "main_worker" {
  subnet_id                 = azurerm_subnet.main_worker.id
  network_security_group_id = azurerm_network_security_group.main_worker.id
}
resource "azurerm_subnet_network_security_group_association" "main_service" {
  subnet_id                 = azurerm_subnet.main_service.id
  network_security_group_id = azurerm_network_security_group.main_service.id
}
resource "azurerm_subnet_network_security_group_association" "main_bastion" {
  subnet_id                 = azurerm_subnet.main_bastion.id
  network_security_group_id = azurerm_network_security_group.main_bastion.id
}

#
# NAT Gateway
#

resource "azurerm_public_ip" "main" {
  name                = "ip-01"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_nat_gateway" "main" {
  name                = "ng-01"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}

resource "azurerm_nat_gateway_public_ip_association" "main" {
  nat_gateway_id       = azurerm_nat_gateway.main.id
  public_ip_address_id = azurerm_public_ip.main.id
}

resource "azurerm_subnet_nat_gateway_association" "main_control" {
  subnet_id      = azurerm_subnet.main_control.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}
resource "azurerm_subnet_nat_gateway_association" "main_worker" {
  subnet_id      = azurerm_subnet.main_worker.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}

resource "azurerm_subnet_nat_gateway_association" "main_bastion" {
  subnet_id      = azurerm_subnet.main_bastion.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}

#
# Load Balancer
#

resource "azurerm_lb" "main_control" {
  name                = "lb-01"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                          = "default"
    subnet_id                     = azurerm_subnet.main_control.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.settings.network.load_balancer.frontend.ip_address
  }

  sku      = "Standard"
  sku_tier = "Regional"
}

resource "azurerm_lb_backend_address_pool" "main_control" {
  name            = "default"
  loadbalancer_id = azurerm_lb.main_control.id
}

resource "azurerm_lb_probe" "main_control" {
  name            = "kube-apiserver"
  loadbalancer_id = azurerm_lb.main_control.id

  port = 6443
}

resource "azurerm_lb_rule" "main_control" {
  name            = "kube-apiserver"
  loadbalancer_id = azurerm_lb.main_control.id

  frontend_ip_configuration_name = "default"
  backend_address_pool_ids = [
    azurerm_lb_backend_address_pool.main_control.id
  ]
  probe_id = azurerm_lb_probe.main_control.id

  protocol      = "Tcp"
  frontend_port = 6443
  backend_port  = 6443
}
