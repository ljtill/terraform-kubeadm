#
# Virtual Network
#

resource "azurerm_virtual_network" "main" {
  name                = var.resource_names.virtual_network
  location            = var.location
  resource_group_name = var.resource_group_name

  address_space = ["172.16.0.0/16"]
}

resource "azurerm_subnet" "main_default" {
  name                = "DefaultSubnet"
  resource_group_name = var.resource_group_name

  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["172.16.0.0/24"]
}
resource "azurerm_subnet" "main_control" {
  name                = "ControlSubnet"
  resource_group_name = var.resource_group_name

  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["172.16.1.0/24"]
}
resource "azurerm_subnet" "main_data" {
  name                = "DataSubnet"
  resource_group_name = var.resource_group_name

  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["172.16.2.0/24"]
}
resource "azurerm_subnet" "main_bastion" {
  name                = "AzureBastionSubnet"
  resource_group_name = var.resource_group_name

  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["172.16.250.0/24"]
}

#
# Security Group
#

resource "azurerm_network_security_group" "main" {
  name                = var.resource_names.security_group
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "main_default" {
  subnet_id                 = azurerm_subnet.main_default.id
  network_security_group_id = azurerm_network_security_group.main.id
}
resource "azurerm_subnet_network_security_group_association" "main_control" {
  subnet_id                 = azurerm_subnet.main_control.id
  network_security_group_id = azurerm_network_security_group.main.id
}
resource "azurerm_subnet_network_security_group_association" "main_data" {
  subnet_id                 = azurerm_subnet.main_data.id
  network_security_group_id = azurerm_network_security_group.main.id
}
resource "azurerm_subnet_network_security_group_association" "main_bastion" {
  subnet_id                 = azurerm_subnet.main_bastion.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_network_security_rule" "main_internet_https" {
  name                        = "AllowHttpsInbound"
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.resource_names.security_group

  priority                   = 120
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "443"
  source_address_prefix      = "Internet"
  destination_address_prefix = "*"
}
resource "azurerm_network_security_rule" "main_gateway" {
  name                        = "AllowGatewayManagerInbound"
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.resource_names.security_group

  priority                   = 130
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "443"
  source_address_prefix      = "GatewayManager"
  destination_address_prefix = "*"
}
resource "azurerm_network_security_rule" "main_loadbalancer" {
  name                        = "AllowAzureLoadBalancerInbound"
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.resource_names.security_group

  priority                   = 140
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "443"
  source_address_prefix      = "AzureLoadBalancer"
  destination_address_prefix = "*"
}
resource "azurerm_network_security_rule" "main_host" {
  name                        = "AllowBastionHostCommunication"
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.resource_names.security_group

  priority                   = 150
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "*"
  source_port_range          = "*"
  destination_port_ranges    = ["8080", "5701"]
  source_address_prefix      = "VirtualNetwork"
  destination_address_prefix = "VirtualNetwork"
}
resource "azurerm_network_security_rule" "main_sshrdp" {
  name                        = "AllowSshRdpOutbound"
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.resource_names.security_group

  priority                   = 100
  direction                  = "Outbound"
  access                     = "Allow"
  protocol                   = "*"
  source_port_range          = "*"
  destination_port_ranges    = ["22", "3389"]
  source_address_prefix      = "*"
  destination_address_prefix = "VirtualNetwork"
}
resource "azurerm_network_security_rule" "main_cloud" {
  name                        = "AllowAzureCloudOutbound"
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.resource_names.security_group

  priority                   = 110
  direction                  = "Outbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "443"
  source_address_prefix      = "*"
  destination_address_prefix = "AzureCloud"
}
resource "azurerm_network_security_rule" "main_bastion" {
  name                        = "AllowBastionCommunication"
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.resource_names.security_group

  priority                   = 120
  direction                  = "Outbound"
  access                     = "Allow"
  protocol                   = "*"
  source_port_range          = "*"
  destination_port_ranges    = ["8080", "5701"]
  source_address_prefix      = "VirtualNetwork"
  destination_address_prefix = "VirtualNetwork"
}
resource "azurerm_network_security_rule" "main_internet_http" {
  name                        = "AllowHttpOutbound"
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.resource_names.security_group

  priority                   = 130
  direction                  = "Outbound"
  access                     = "Allow"
  protocol                   = "*"
  source_port_range          = "*"
  destination_port_range     = "80"
  source_address_prefix      = "*"
  destination_address_prefix = "Internet"
}

#
# Bastion
#

resource "azurerm_public_ip" "main" {
  name                = "${var.resource_names.public_ip}-01"
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_bastion_host" "main" {
  name                = var.resource_names.bastion_host
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "IpConf"
    subnet_id            = azurerm_subnet.main_bastion.id
    public_ip_address_id = azurerm_public_ip.main.id
  }

  sku = "Standard"
}

#
# Load Balancer
#

resource "azurerm_lb" "main" {
  name                = var.resource_names.load_balancer
  location            = var.location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                          = "ControlPlane"
    subnet_id                     = azurerm_subnet.main_control.id
    private_ip_address_allocation = "Dynamic"
  }

  frontend_ip_configuration {
    name                          = "DataPlane"
    subnet_id                     = azurerm_subnet.main_data.id
    private_ip_address_allocation = "Dynamic"
  }

  sku      = "Standard"
  sku_tier = "Regional"
}
