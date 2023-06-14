#
# Defaults
#

variable "settings" {
  type = object({
    location        = string
    resource_groups = map(string)
    compute = object({
      credentials = object({
        username     = string
        ssh_key_path = string
      })
      image = object({
        publisher = string
        offer     = string
        sku       = string
        version   = string
      })
      bastion = object({
        ip_address = string
        size       = string
        disk_type  = string
      })
      virtual_machines = object({
        size      = string
        disk_type = string
        primary = object({
          ip_address = string
        })
        secondary = object({
          ip_address = string
        })
        tertiary = object({
          ip_address = string
        })
      })
      virtual_machine_scale_sets = object({
        size      = string
        disk_type = string
        instances = object({
          default = number
          minimum = number
          maximum = number
        })
      })
    })
    network = object({
      dns_zone = object({
        name = string
        records = object({
          apiserver = string
        })
      })
      subnet_ids = object({
        control = string
        worker  = string
        bastion = string
      })
      backend_ids = object({
        control = string
        worker  = string
      })
    })
    identity = object({
      principal_ids = object({
        control = string
        worker  = string
      })
      user_ids = object({
        control = string
        worker  = string
      })
    })
  })
}
