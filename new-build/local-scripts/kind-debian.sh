#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/kubectl-helm.md
# Maintainer: The VS Code and Codespaces Teams
#
# Syntax: ./kubectl-helm-debian.sh [kubectl verison] [Helm version] [minikube version] [kubectl SHA256] [Helm SHA256] [minikube SHA256]

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# Install curl if missing
if ! dpkg -s curl ca-certificates coreutils gnupg2 > /dev/null 2>&1; then
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        apt-get update
    fi
    apt-get -y install --no-install-recommends apt-utils dialog
    apt-get -y install --no-install-recommends ca-certificates apt-transport-https
    apt-get -y install --no-install-recommends wget curl coreutils gnupg2
fi

### TODO - do we need this?
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key --keyring /etc/apt/trusted.gpg.d/docker.gpg add -
#add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
#curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
#echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
#apt-get update

#apt-get -y install --no-install-recommends containerd.io kubelet kubernetes-cni kubeadm

# install kind
curl -Lo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v0.10.0/kind-linux-amd64
chmod +x /usr/local/bin/kind

# install k3d
#wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash

# install k9s
curl -Lo ./k9s.tar.gz https://github.com/derailed/k9s/releases/download/v0.24.2/k9s_Linux_x86_64.tar.gz
mkdir k9s
tar xvzf k9s.tar.gz -C ./k9s
mv ./k9s/k9s /usr/local/bin/k9s
rm -rf k9s.tar.gz k9s

# install fluxctl
curl -L https://github.com/fluxcd/flux/releases/download/1.14.2/fluxctl_linux_amd64 -o /usr/local/bin/fluxctl
chmod +x /usr/local/bin/fluxctl

#install istioctl
export ISTIO_VERSION=1.10.1
export ISTIO_HOME=/usr/local/istio

curl -L https://istio.io/downloadIstio | sh -
mv istio-$ISTIO_VERSION $ISTIO_HOME

# create directories
mkdir -p /etc/containerd
mkdir -p /etc/systemd/system/docker.service.d
mkdir -p /etc/docker
mkdir -p /prometheus
mkdir -p /grafana
chown -R 65534:65534 /prometheus
chown -R 472:472 /grafana

# add env vars to .bashrc
echo "export FLUX_FORWARD_NAMESPACE=flux-cd" >> /home/${USERNAME}/.bashrc
echo "export ISTIO_VERSION=$ISTIO_VERSION" >> /home/${USERNAME}/.bashrc
echo "export ISTIO_HOME=$ISTIO_HOME" >> /home/${USERNAME}/.bashrc
echo 'export PATH=$ISTIO_HOME/bin:$PATH' >> /home/${USERNAME}/.bashrc

echo -e "\nDone!"
