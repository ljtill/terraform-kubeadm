#
# Defaults
#

variable "settings" {
  type = object({
    location        = string
    resource_groups = map(string)
    network = object({
      dns_zone = object({
        name = string
        records = object({
          apiserver = string
        })
      })
      virtual_network = object({
        address_space = string
        subnets = map(object({
          address_prefix = string
        }))
      })
      load_balancer = object({
        frontend = object({
          ip_address = string
        })
      })
    })
    identity = object({
      principal_ids = object({
        control_plane = string
        worker_plane  = string
      })
      user_ids = object({
        control_plane = string
        worker_plane  = string
      })
    })
  })
}
