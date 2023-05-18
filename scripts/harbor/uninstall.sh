#!/usr/bin/env bash

uninstall_chart() {
    helm status harbor --namespace kube-harbor &>/dev/null
    if [ $? -eq 0 ]; then
        helm uninstall harbor --namespace kube-harbor
        kubectl delete namespace kube-harbor
    fi
}

{
    uninstall_chart
}
