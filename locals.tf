locals {
  location            = "uksouth"
  resource_group_name = "RG-01"

  resource_names = {
    virtual_network = "VN-01"
    security_group  = "SG-01"
    public_ip       = "IP-01"
    bastion_host    = "BH-01"
    load_balancer   = "LB-01"
  }

  resource_prefixes = {
    network_interface = "NI"
    virtual_machine   = "VM"
    os_disk           = "DS"
  }
}
