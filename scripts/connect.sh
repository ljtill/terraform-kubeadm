#!/usr/bin/env bash
set -e

{
    echo "=> Connecting to bastion"
    ssh -i .ssh/id_rsa -J adminuser@$(terraform output -raw bastion_public_ip) adminuser@172.16.1.5
}
