output "bastion" {
  value = {
    public_ip = module.bastion.public_ip
  }
}
