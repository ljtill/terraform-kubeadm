#
# Defaults
#

variable "resource_groups" {
  type = map(string)
}
variable "location" {
  type = string
}

#
# Resources
#

variable "domains" {
  type = map(string)
}

variable "resource_ids" {
  type = map(string)
}

variable "subnet_ids" {
  type = map(string)
}
variable "backend_ids" {
  type = map(string)
}
