#
# Defaults
#

variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}

#
# Resources
#

variable "resource_names" {
  type = map(string)
}
variable "resource_prefixes" {
  type = map(string)
}