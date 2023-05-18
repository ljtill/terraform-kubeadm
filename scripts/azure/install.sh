#!/usr/bin/env bash

install_secret() {
    kubectl apply -f ./manifests/kubernetes/secrets.yaml -n kube-system
}

install_controller() {
    helm status cloud-provider-azure --namespace kube-system &>/dev/null
    if [ $? -eq 1 ]; then
        echo "=> Installing cloud controller..."
        helm install cloud-provider-azure \
        --repo https://raw.githubusercontent.com/kubernetes-sigs/cloud-provider-azure/master/helm/repo cloud-provider-azure \
        --namespace kube-system \
        --set cloudControllerManager.imageRepository=mcr.microsoft.com/oss/kubernetes \
        --set cloudControllerManager.imageName=azure-cloud-controller-manager \
        --set cloudControllerManager.enabled=true \
        --set cloudControllerManager.configureCloudRoutes=false \
        --set cloudControllerManager.allocateNodeCidrs=false \
        --set cloudControllerManager.cloudConfigSecretName=cloud-config \
        --set cloudControllerManager.enableDynamicReloading=true \
        --set cloudControllerManager.cloudConfig="" \
        --set cloudNodeManager.imageRepository=mcr.microsoft.com/oss/kubernetes \
        --set cloudNodeManager.imageName=azure-cloud-node-manager \
        --set cloudNodeManager.enabled=true
    fi
}

install_driver() {
    helm status azuredisk-csi-driver --namespace kube-system &>/dev/null
    if [ $? -eq 1 ]; then
        echo "=> Installing csi drivers (disk)..."
        helm install azuredisk-csi-driver \
        --repo https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/charts azuredisk-csi-driver \
        --namespace kube-system \
        --set controller.runOnControlPlane=true \
        --set controller.cloudConfigSecretName=cloud-config \
        --set node.cloudConfigSecretName=cloud-config

        echo "=> Deploying storage class (disk)..."
        kubectl create -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/storageclass-azuredisk-csi.yaml
        kubectl patch storageclass managed-csi -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
    fi
}

install_command() {
    if [ -z "$(which az)" ]; then
        echo "=> Installing packages (azure-cli)..."
        sudo apt-get update
        sudo apt-get install ca-certificates curl apt-transport-https lsb-release gnupg

        sudo mkdir -p /etc/apt/keyrings
        curl -sLS https://packages.microsoft.com/keys/microsoft.asc |
        gpg --dearmor |
        sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
        sudo chmod go+r /etc/apt/keyrings/microsoft.gpg

        AZ_REPO=$(lsb_release -cs)
        echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list

        sudo apt-get update
        sudo apt-get install azure-cli
    fi
}

{
    install_controller
    install_driver
    install_command
}
