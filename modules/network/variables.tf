#
# Defaults
#

variable "settings" {
  type = object({
    location        = string
    resource_groups = map(string)
    network = object({
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
  })
}
