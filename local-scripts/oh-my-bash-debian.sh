#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# Install git if missing
if ! dpkg -s git ca-certificates > /dev/null 2>&1; then
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        apt-get update
    fi
    apt-get -y install --no-install-recommends apt-utils dialog
    apt-get -y install --no-install-recommends ca-certificates apt-transport-https
    apt-get -y install --no-install-recommends git
fi

# install oh-my-bash
rm -rf /home/${USERNAME}/.oh-my-bash
export OSH=/home/${USERNAME}/.oh-my-bash
git clone --depth=1 https://github.com/ohmybash/oh-my-bash.git $OSH
mv /home/${USERNAME}/.bashrc /home/${USERNAME}/.bashrc.pre-oh-my-bash
cp $OSH/templates/bashrc.osh-template /home/${USERNAME}/.bashrc

echo -e "\nDone!"
