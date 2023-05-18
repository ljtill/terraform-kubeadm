#
# Defaults
#

variable "settings" {
  type = object({
    resource_groups = map(string)
    location        = string
  })
}
