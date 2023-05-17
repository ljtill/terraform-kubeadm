#!/usr/bin/env bash
set -e

variables() {
    if [ -z "$ARM_SUBSCRIPTION_ID" ]; then
        echo "Variable ARM_SUBSCRIPTION_ID is unset"
        exit 1
    fi
    if [ -z "$ARM_RESOURCE_GROUP" ]; then
        echo "Variable ARM_RESOURCE_GROUP is unset"
        exit 1
    fi
    if [ -z "$ARM_BASTION_RESOURCE_GROUP" ]; then
        echo "Variable ARM_BASTION_RESOURCE_GROUP is unset"
        exit 1
    fi
    if [ -z "$ARM_BASTION_NAME" ]; then
        echo "Variable ARM_BASTION_NAME is unset"
        exit 1
    fi
}

{
    export $(cat azure.env | xargs)
    variables
    echo "=> Connecting to $1"
    az network bastion tunnel \
        --name "$ARM_BASTION_NAME" \
        --resource-group "$ARM_BASTION_RESOURCE_GROUP" \
        --target-resource-id "/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$ARM_RESOURCE_GROUP/providers/Microsoft.Compute/virtualMachines/$1" \
        --resource-port 22 \
        --port 3000
}
