FROM mcr.microsoft.com/vscode/devcontainers/base:focal

# [Option] Install zsh
ARG INSTALL_ZSH="false"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="false"
# [Option] Enable non-root Docker access in container
ARG ENABLE_NONROOT_DOCKER="true"
# [Option] Use the OSS Moby Engine instead of the licensed Docker Engine
ARG USE_MOBY="false"

# Install needed packages and setup non-root user. Use a separate RUN statement to add your
# own dependencies. A user of "automatic" attempts to reuse an user ID if one already exists.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

###
# We intentionally create multiple layers so that they pull in parallel which improves startup time
###

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update

RUN apt-get -y install --no-install-recommends apt-utils dialog
RUN apt-get -y install --no-install-recommends apt-transport-https ca-certificates
RUN apt-get -y install --no-install-recommends curl git wget
RUN apt-get -y install --no-install-recommends software-properties-common make build-essential
RUN apt-get -y install --no-install-recommends jq bash-completion
RUN apt-get -y install --no-install-recommends httpie
RUN apt-get -y install --no-install-recommends gettext iputils-ping

COPY script-library/*.sh /tmp/script-library/

RUN /bin/bash /tmp/script-library/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" && \
    /bin/bash /tmp/script-library/docker-in-docker-debian.sh "${ENABLE_NONROOT_DOCKER}" "${USERNAME}" "${USE_MOBY}" && \
    rm -rf /tmp/script-library/

VOLUME [ "/var/lib/docker" ]

# Setting the ENTRYPOINT to docker-init.sh will start up the Docker Engine 
# inside the container "overrideCommand": false is set in devcontainer.json. 
# The script will also execute CMD if you need to alter startup behaviors.
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]

RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.asc.gpg && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/azure-cli.list && \
    apt-get update

RUN apt-get install -y --no-install-recommends dotnet-sdk-5.0
RUN apt-get -y install --no-install-recommends azure-cli

# jp (jmespath)
RUN VERSION=$(curl -i https://github.com/jmespath/jp/releases/latest | grep "location: https://github.com/" | rev | cut -f 1 -d / | rev | sed 's/\r//') && \
    wget https://github.com/jmespath/jp/releases/download/$VERSION/jp-linux-amd64 -O /usr/local/bin/jp && \
    chmod +x /usr/local/bin/jp

RUN apt-get upgrade -y

RUN apt-get autoremove -y && \
    apt-get clean -y

# install other tools
RUN mkdir -p /home/${USERNAME}/.ssh && \
    mkdir -p /home/${USERNAME}/bin && \
    mkdir -p /home/${USERNAME}/.local/bin && \
    mkdir -p /home/${USERNAME}/.dotnet/tools && \
    rm -rf /home/${USERNAME}/.oh-my-bash && \
    export OSH=/home/${USERNAME}/.oh-my-bash && \
    git clone --depth=1 https://github.com/ohmybash/oh-my-bash.git $OSH && \
    mv /home/${USERNAME}/.bashrc /home/${USERNAME}/.bashrc.pre-oh-my-bash && \
    cp $OSH/templates/bashrc.osh-template /home/${USERNAME}/.bashrc && \
    echo >> /home/${USERNAME}/.bashrc && \
    echo "alias ipconfig='ip -4 a show eth0 | grep inet | sed \"s/inet//g\" | sed \"s/ //g\" | cut -d / -f 1'" >> /home/${USERNAME}/.bashrc && \
    echo 'export PIP=$(ipconfig | tail -n 1)' >> /home/${USERNAME}/.bashrc && \
    echo 'export PATH=$PATH:$HOME/.dotnet/tools' >> /home/${USERNAME}/.bashrc && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}
