#
# Virtual Network
#

resource "azurerm_virtual_network" "main" {
  name                = "vn-01"
  location            = var.settings.location
  resource_group_name = var.settings.resource_groups.network

  address_space = [var.settings.network.virtual_network.address_space]
}

resource "azurerm_subnet" "main_control" {
  name                = "ControlSubnet"
  resource_group_name = var.settings.resource_groups.network

  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.settings.network.virtual_network.subnets.control.address_prefix]
}
resource "azurerm_subnet" "main_worker" {
  name                = "WorkerSubnet"
  resource_group_name = var.settings.resource_groups.network

  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.settings.network.virtual_network.subnets.worker.address_prefix]
}
resource "azurerm_subnet" "main_service" {
  name                = "ServiceSubnet"
  resource_group_name = var.settings.resource_groups.network

  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.settings.network.virtual_network.subnets.service.address_prefix]
}
resource "azurerm_subnet" "main_bastion" {
  name                = "AzureBastionSubnet"
  resource_group_name = var.settings.resource_groups.network

  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.settings.network.virtual_network.subnets.bastion.address_prefix]
}

#
# Security Group
#

resource "azurerm_network_security_group" "main_control" {
  name                = "sg-01"
  location            = var.settings.location
  resource_group_name = var.settings.resource_groups.network
}
resource "azurerm_network_security_group" "main_worker" {
  name                = "sg-02"
  location            = var.settings.location
  resource_group_name = var.settings.resource_groups.network
}
resource "azurerm_network_security_group" "main_service" {
  name                = "sg-03"
  location            = var.settings.location
  resource_group_name = var.settings.resource_groups.network
}
resource "azurerm_network_security_group" "main_bastion" {
  name                = "sg-04"
  location            = var.settings.location
  resource_group_name = var.settings.resource_groups.network

  dynamic "security_rule" {
    for_each = local.security_rules
    content {
      name                       = security_rule.value["name"]
      priority                   = security_rule.value["priority"]
      direction                  = security_rule.value["direction"]
      access                     = security_rule.value["access"]
      protocol                   = security_rule.value["protocol"]
      source_port_range          = security_rule.value["source_port_range"]
      source_port_ranges         = security_rule.value["source_port_ranges"]
      destination_port_range     = security_rule.value["destination_port_range"]
      destination_port_ranges    = security_rule.value["destination_port_ranges"]
      source_address_prefix      = security_rule.value["source_address_prefix"]
      destination_address_prefix = security_rule.value["destination_address_prefix"]
    }
  }
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
# Bastion
#

resource "azurerm_public_ip" "main_bastion" {
  name                = "ip-01"
  location            = var.settings.location
  resource_group_name = var.settings.resource_groups.network

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_bastion_host" "main" {
  name                = "bs-01"
  location            = var.settings.location
  resource_group_name = var.settings.resource_groups.network

  ip_configuration {
    name                 = "IpConf"
    subnet_id            = azurerm_subnet.main_bastion.id
    public_ip_address_id = azurerm_public_ip.main_bastion.id
  }

  tunneling_enabled = true
  sku               = "Standard"
}

#
# NAT Gateway
#

resource "azurerm_public_ip" "main_nat" {
  name                = "ip-02"
  location            = var.settings.location
  resource_group_name = var.settings.resource_groups.network

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_nat_gateway" "main" {
  name                = "ng-01"
  location            = var.settings.location
  resource_group_name = var.settings.resource_groups.network

  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}

resource "azurerm_nat_gateway_public_ip_association" "main" {
  nat_gateway_id       = azurerm_nat_gateway.main.id
  public_ip_address_id = azurerm_public_ip.main_nat.id
}

resource "azurerm_subnet_nat_gateway_association" "main_control" {
  subnet_id      = azurerm_subnet.main_control.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}
resource "azurerm_subnet_nat_gateway_association" "main_worker" {
  subnet_id      = azurerm_subnet.main_worker.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}

#
# Load Balancer
#

resource "azurerm_lb" "main_control" {
  name                = "lb-01"
  location            = var.settings.location
  resource_group_name = var.settings.resource_groups.network

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
