#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/kubectl-helm.md
# Maintainer: The VS Code and Codespaces Teams
#
# Syntax: ./dind.sh

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    echo "(!) $0 failed!"
    exit 1
fi

if ! type kubectl > /dev/null 2>&1; then
    echo 'You must run kubectl-helm-debian.sh first'
    echo "(!) $0 failed!"
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# Install required packages
apt-get update
apt-get -y install --no-install-recommends apt-utils dialog
apt-get -y install --no-install-recommends coreutils gnupg2 ca-certificates apt-transport-https
apt-get -y install --no-install-recommends software-properties-common make build-essential
apt-get -y install --no-install-recommends git wget curl bash-completion jq gettext iputils-ping

ARCHITECTURE="$(uname -m)"
case $ARCHITECTURE in
    x86_64) ARCHITECTURE="amd64";;
    aarch64 | armv8*) ARCHITECTURE="arm64";;
    aarch32 | armv7* | armvhf*) ARCHITECTURE="arm";;
    i?86) ARCHITECTURE="386";;
    *) echo "(!) Architecture $ARCHITECTURE unsupported"; exit 1 ;;
esac

echo "Installing httpie ..."

apt-get -y install --no-install-recommends python3 python3-pip
pip3 install --upgrade pip setuptools httpie

echo "Installing jmespath ..."

JP_VERSION=$(basename "$(curl -fsSL -o /dev/null -w "%{url_effective}" https://github.com/jmespath/jp/releases/latest)")
curl -Lo /usr/local/bin/jp https://github.com/jmespath/jp/releases/download/${JP_VERSION}/jp-linux-${ARCHITECTURE}
chmod +x /usr/local/bin/jp

echo "Updating config ..."
echo -e 'export PATH=$PATH:$HOME/.dotnet/tools' | tee -a /etc/zsh/zshrc >> /etc/bash.bashrc

echo -e "alias k='kubectl'" | tee -a /etc/zsh/zshrc >> /etc/bash.bashrc
echo -e "alias kga='kubectl get all'" | tee -a /etc/zsh/zshrc >> /etc/bash.bashrc
echo -e "alias kgaa='kubectl get all --all-namespaces'" | tee -a /etc/zsh/zshrc >> /etc/bash.bashrc
echo -e "alias kaf='kubectl apply -f'" | tee -a /etc/zsh/zshrc >> /etc/bash.bashrc
echo -e "alias kdelf='kubectl delete -f'" | tee -a /etc/zsh/zshrc >> /etc/bash.bashrc
echo -e "alias kl='kubectl logs'" | tee -a /etc/zsh/zshrc >> /etc/bash.bashrc
echo -e "alias kccc='kubectl config current-context'" | tee -a /etc/zsh/zshrc >> /etc/bash.bashrc
echo -e "alias kcgc='kubectl config get-contexts'" | tee -a /etc/zsh/zshrc >> /etc/bash.bashrc
echo -e "alias kj='kubectl exec -it jumpbox -- bash -l'" | tee -a /etc/zsh/zshrc >> /etc/bash.bashrc
echo -e "alias kje='kubectl exec -it jumpbox -- '" | tee -a /etc/zsh/zshrc >> /etc/bash.bashrc
echo -e "alias ipconfig='ip -4 a show eth0 | grep inet | sed \"s/inet//g\" | sed \"s/ //g\" | cut -d / -f 1'" | tee -a /etc/zsh/zshrc >> /etc/bash.bashrc
echo -e "export GO111MODULE=on" | tee -a /etc/zsh/zshrc >> /etc/bash.bashrc
echo -e 'export PIP=$(ipconfig | tail -n 1)' | tee -a /etc/zsh/zshrc >> /etc/bash.bashrc

# bash only
echo -e "complete -F __start_kubectl k" >> /etc/bash.bashrc

if ! type docker > /dev/null 2>&1; then
    echo -e '\n(*) Warning: The docker command was not found.\n\nYou can use one of the following scripts to install it:\n\nhttps://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/docker-in-docker.md\n\nor\n\nhttps://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/docker.md'
fi

echo -e "\n${0} Done!"
