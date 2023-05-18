#!/usr/bin/env bash
set -e

upload() {
    echo "=> Creating directory (scripts)..."
    ssh -i .ssh/id_rsa -J adminuser@$(terraform output -raw bastion_public_ip) adminuser@172.16.1.5 'mkdir -p /home/adminuser/scripts/azure'
    ssh -i .ssh/id_rsa -J adminuser@$(terraform output -raw bastion_public_ip) adminuser@172.16.1.5 'mkdir -p /home/adminuser/scripts/harbor'

    echo "=> Creating directory (manifests)..."
    ssh -i .ssh/id_rsa -J adminuser@$(terraform output -raw bastion_public_ip) adminuser@172.16.1.5 'mkdir -p /home/adminuser/manifests/kubernetes'

    echo "=> Uploading files (scripts)..."
    scp -i .ssh/id_rsa -o "ProxyJump adminuser@$(terraform output -raw bastion_public_ip)" ./scripts/azure/install.sh adminuser@172.16.1.5:/home/adminuser/scripts/azure/install.sh
    scp -i .ssh/id_rsa -o "ProxyJump adminuser@$(terraform output -raw bastion_public_ip)" ./scripts/azure/uninstall.sh adminuser@172.16.1.5:/home/adminuser/scripts/azure/uninstall.sh
    scp -i .ssh/id_rsa -o "ProxyJump adminuser@$(terraform output -raw bastion_public_ip)" ./scripts/harbor/install.sh adminuser@172.16.1.5:/home/adminuser/scripts/harbor/install.sh
    scp -i .ssh/id_rsa -o "ProxyJump adminuser@$(terraform output -raw bastion_public_ip)" ./scripts/harbor/uninstall.sh adminuser@172.16.1.5:/home/adminuser/scripts/harbor/uninstall.sh

    echo "=> Uploading files (manifests)..."
    scp -i .ssh/id_rsa -o "ProxyJump adminuser@$(terraform output -raw bastion_public_ip)" ./templates/kubernetes/secret.yaml adminuser@172.16.1.5:/home/adminuser/manifests/kubernetes/secret.yaml
}

{
    upload
}
