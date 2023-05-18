#!/usr/bin/env bash

uninstall_controller() {
    helm status cloud-provider-azure --namespace kube-system &>/dev/null
    if [ $? -eq 0 ]; then
        echo "=> Uninstalling cloud controller..."
        helm uninstall cloud-provider-azure \
        --namespace kube-system
    fi
}

uninstall_driver() {
    helm status azuredisk-csi-driver --namespace kube-system &>/dev/null
    if [ $? -eq 0 ]; then
        echo "=> Uninstalling csi drivers (disk)..."
        helm uninstall azuredisk-csi-driver \
        --namespace kube-system

        echo "=> Deleting storage class (disk)..."
        kubectl delete storageclass managed-csi
    fi
}

uninstall_secret() {
    kubectl delete -f ./manifests/kubernetes/secret.yaml -n kube-system
}

{
    uninstall_controller
    uninstall_driver
    uninstall_secret
}
