###### Build Docker-in-Docker container

FROM mcr.microsoft.com/vscode/devcontainers/base:focal as dind

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
RUN apt-get -y install --no-install-recommends gettext iputils-ping
RUN apt-get -y install --no-install-recommends httpie

# use scripts from: https://github.com/microsoft/vscode-dev-containers/tree/main/script-library
COPY script-library/*.sh /tmp/script-library/
RUN /bin/bash /tmp/script-library/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}"
RUN /bin/bash /tmp/script-library/docker-in-docker-debian.sh "${ENABLE_NONROOT_DOCKER}" "${USERNAME}" "${USE_MOBY}"
RUN /bin/bash /tmp/script-library/kubectl-helm-debian.sh
RUN /bin/bash /tmp/script-library/azcli-debian.sh
RUN rm -rf /tmp/script-library/

# run local scripts
COPY local-scripts/*.sh /tmp/script-library/
RUN /bin/bash /tmp/script-library/oh-my-bash-debian.sh
RUN /bin/bash /tmp/script-library/dind-debian.sh
RUN /bin/bash /tmp/script-library/dotnet-debian.sh
RUN rm -rf /tmp/script-library/

VOLUME [ "/var/lib/docker" ]

# Setting the ENTRYPOINT to docker-init.sh will start up the Docker Engine 
# inside the container "overrideCommand": false is set in devcontainer.json. 
# The script will also execute CMD if you need to alter startup behaviors.
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]

RUN apt-get upgrade -y

RUN apt-get autoremove -y && \
    apt-get clean -y


#######################
### Build kind container from Docker-in-Docker

FROM dind

COPY local-scripts/*.sh /tmp/script-library/
RUN /bin/bash /tmp/script-library/kind-debian.sh && \
    rm -rf /tmp/script-library/
