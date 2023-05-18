#!/usr/bin/env bash
set -e

variables() {
    export $(cat azure.env | xargs)
    if [ -z "$ARM_BASTION_ADDRESS" ]; then
        echo "Variable ARM_BASTION_ADDRESS is unset"
        exit 1
    fi
}

{
    variables
    echo "=> Connecting to $1"
    ssh -i .ssh/id_rsa -J adminuser@$ARM_BASTION_ADDRESS adminuser@172.16.1.5
}
