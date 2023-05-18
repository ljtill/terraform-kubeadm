locals {
  compute = {
    credentials = {
      username     = "adminuser"
      ssh_key_path = ".ssh/id_rsa.pub"
    }
    image = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts-gen2"
      version   = "latest"
    }
    bastion = {
      ip_address = "172.16.10.4"
      size       = "Standard_D2s_v5"
      disk_type  = "Premium_LRS"
    }
    virtual_machines = {
      size      = "Standard_D8s_v5"
      disk_type = "Premium_LRS"
      primary = {
        ip_address = "172.16.1.5"
      }
      secondary = {
        ip_address = "172.16.1.6"
      }
      tertiary = {
        ip_address = "172.16.1.7"
      }
    }
    virtual_machine_scale_sets = {
      size      = "Standard_D8s_v5"
      disk_type = "Premium_LRS"
      instances = {
        default = 5
        minimum = 3
        maximum = 10
      }
    }
  }
}
