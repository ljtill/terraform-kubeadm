locals {
  network = {
    dns_zone = {
      name = ""
      records = {
        apiserver = "172.16.1.4"
      }
    },
    virtual_network = {
      address_space = "172.16.0.0/16"
      subnets = {
        control = {
          address_prefix = "172.16.1.0/24"
        }
        worker = {
          address_prefix = "172.16.2.0/24"
        }
        service = {
          address_prefix = "172.16.5.0/24"
        }
        bastion = {
          address_prefix = "172.16.10.0/24"
        }
      }
    }
    load_balancer = {
      frontend = {
        ip_address = "172.16.1.4"
      }
    }
  }
}
