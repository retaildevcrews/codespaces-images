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
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# Install wget if missing
if ! dpkg -s curl ca-certificates coreutils gnupg2 > /dev/null 2>&1; then
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        apt-get update
    fi
    apt-get -y install --no-install-recommends apt-utils dialog
    apt-get -y install --no-install-recommends ca-certificates apt-transport-https
    apt-get -y install --no-install-recommends wget curl coreutils gnupg2
fi

# jp (jmespath)
VERSION=$(curl -i https://github.com/jmespath/jp/releases/latest | grep "location: https://github.com/" | rev | cut -f 1 -d / | rev | sed 's/\r//')
wget https://github.com/jmespath/jp/releases/download/$VERSION/jp-linux-amd64 -O /usr/local/bin/jp
chmod +x /usr/local/bin/jp

# make directories
mkdir -p /home/${USERNAME}/.ssh
mkdir -p /home/${USERNAME}/bin
mkdir -p /home/${USERNAME}/.local/bin
mkdir -p /home/${USERNAME}/.dotnet/tools
mkdir -p /home/${USERNAME}/.kube
mkdir -p /home/${USERNAME}/.k9s
mkdir -p /home/${USERNAME}/go/src

# set aliases
echo "alias k='kubectl'" >> /home/${USERNAME}/.bashrc
echo "alias kga='kubectl get all'" >> /home/${USERNAME}/.bashrc
echo "alias kgaa='kubectl get all --all-namespaces'" >> /home/${USERNAME}/.bashrc
echo "alias kaf='kubectl apply -f'" >> /home/${USERNAME}/.bashrc
echo "alias kdelf='kubectl delete -f'" >> /home/${USERNAME}/.bashrc
echo "alias kl='kubectl logs'" >> /home/${USERNAME}/.bashrc
echo "alias kccc='kubectl config current-context'" >> /home/${USERNAME}/.bashrc
echo "alias kcgc='kubectl config get-contexts'" >> /home/${USERNAME}/.bashrc
echo "alias kj='kubectl exec -it jumpbox -- bash -l'" >> /home/${USERNAME}/.bashrc
echo "alias kje='kubectl exec -it jumpbox -- '" >> /home/${USERNAME}/.bashrc
echo "alias ipconfig='ip -4 a show eth0 | grep inet | sed \"s/inet//g\" | sed \"s/ //g\" | cut -d / -f 1'" >> /home$    echo "export GO111MODULE=on" >> /home/${USERNAME}/.bashrc

# set env vars
echo 'export PIP=$(ipconfig | tail -n 1)' >> /home/${USERNAME}/.bashrc
echo 'export PATH=$PATH:$HOME/.dotnet/tools' >> /home/${USERNAME}/.bashrc

# kubectl (and "k") completion
echo 'complete -F __start_kubectl k' >> /home/${USERNAME}/.bashrc
kubectl completion bash > /etc/bash_completion.d/kubectl

# change owner
chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

echo -e "\nDone!"
