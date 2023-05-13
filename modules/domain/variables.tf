#
# Defaults
#

variable "resource_groups" {
  type = map(string)
}

#
# Resources
#

variable "domains" {
  type = map(string)
}
variable "virtual_network_id" {
  type = string
}
