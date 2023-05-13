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

variable "token_id" {
  type = string
}
variable "token_secret" {
  type = string
}

variable "certificate_key" {
  type = string
}

variable "domains" {
  type = map(string)
}

variable "resource_ids" {
  type = map(string)
}

variable "subnet_ids" {
  type = map(string)
}
