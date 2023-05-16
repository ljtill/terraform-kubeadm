#
# Defaults
#

variable "settings" {
  type = object({
    resource_groups = map(string)
    domain = object({
      dns_zone = string
      records = object({
        apiserver = string
      })
    })
    network = object({
      virtual_network_id = string
    })
  })
}
