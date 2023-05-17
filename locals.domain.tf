locals {
  domain = {
    dns_zone = "azk8s.dev"
    records = {
      apiserver = "172.16.1.4"
    }
  }
}
