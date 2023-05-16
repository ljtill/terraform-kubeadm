#
# Defaults
#

variable "settings" {
  type = object({
    location        = string
    resource_groups = map(string)
    cluster = object({
      token_id        = string
      token_secret    = string
      certificate_key = string
    })
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
    })
    domain = object({
      dns_zone = string
      records = object({
        apiserver = string
      })
    })
    network = object({
      subnet_ids = object({
        control_plane = string
        worker_plane  = string
      })
      backend_ids = object({
        control_plane = string
        worker_plane  = string
      })
    })
  })
}