variable "settings" {
  type = object({
    resource_groups = map(string)
    location        = string
    identity = object({
      principal_ids = object({
        control_plane = string
        worker_plane  = string
      })
    })
  })
}
