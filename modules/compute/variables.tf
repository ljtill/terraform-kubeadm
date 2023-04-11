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

variable "resource_prefixes" {
  type = map(string)
}

variable "node_count" {
  type = map(number)
}

variable "subnet_ids" {
  type = map(string)
}
