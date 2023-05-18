#!/usr/bin/env bash

download_chart() {
    helm repo add harbor https://helm.goharbor.io &>/dev/null
    helm repo update
}

install_chart() {
    helm status harbor --namespace kube-harbor &>/dev/null
    if [ $? -eq 1 ]; then
        helm install harbor harbor/harbor --namespace kube-harbor --create-namespace
    fi
}

{
    download_chart
    install_chart
}
