###### Build Docker-in-Docker image
FROM mcr.microsoft.com/vscode/devcontainers/dotnet as dind

# user args
# some base images require specific values
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# copy the stup scripts to the image
COPY library-scripts/*.sh /scripts/
COPY local-scripts/*.sh /scripts/

###
# We intentionally create multiple layers so that they pull in parallel which improves startup time
###

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update

RUN apt-get -y install --no-install-recommends apt-utils dialog
RUN apt-get -y install --no-install-recommends apt-transport-https ca-certificates
RUN apt-get -y install --no-install-recommends curl git wget
RUN apt-get -y install --no-install-recommends software-properties-common make build-essential
RUN apt-get -y install --no-install-recommends jq bash-completion
RUN apt-get -y install --no-install-recommends gettext iputils-ping dnsutils 

# use scripts from: https://github.com/microsoft/vscode-dev-containers/tree/main/script-library
# uncomment this if you use a base image other than a Codespaces image
# RUN /bin/bash /scripts/common-debian.sh
RUN /bin/bash /scripts/docker-in-docker-debian.sh
RUN /bin/bash /scripts/kubectl-helm-debian.sh
RUN /bin/bash /scripts/azcli-debian.sh

# run local scripts
RUN /bin/bash /scripts/dind-debian.sh

RUN echo "👋 Welcome to Codespaces! You are on a custom image defined in your devcontainer.json file.\n" > /usr/local/etc/vscode-dev-containers/first-run-notice.txt \
    && echo "🔍 To explore VS Code to its fullest, search using the Command Palette (Cmd/Ctrl + Shift + P)\n" >> /usr/local/etc/vscode-dev-containers/first-run-notice.txt \
    && echo "👋 Welcome to the Docker-in-Docker image\n" >> /usr/local/etc/vscode-dev-containers/first-run-notice.txt

VOLUME [ "/var/lib/docker" ]

# Setting the ENTRYPOINT to docker-init.sh will start up the Docker Engine 
# inside the container "overrideCommand": false is set in devcontainer.json. 
# The script will also execute CMD if you need to alter startup behaviors.
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get autoremove -y && \
    apt-get clean -y

WORKDIR /home/${USERNAME}
USER ${USERNAME}

# install https://aka.ms/webv
RUN dotnet tool install -g webvalidate

USER root

#######################
### Build ngsa-java image from Docker-in-Docker
FROM dind as ngsa-java

ARG USERNAME="vscode"
ARG JAVA_VERSION="11"
ARG MAVEN_VERSION="3.6.3"
ARG ZULU_VERSION="1.0.0-2"

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update

RUN apt-get -y install --no-install-recommends libssl-dev gnupg-agent

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xB1998361219BD9C9 && \
    curl -O https://cdn.azul.com/zulu/bin/zulu-repo_${ZULU_VERSION}_all.deb && \
    apt-get install ./zulu-repo_${ZULU_VERSION}_all.deb && \
    apt-get update && \
    apt-get -y install zulu${JAVA_VERSION}-jdk

RUN /bin/bash /scripts/maven-debian.sh

ENV PATH=/apache-maven/bin:${PATH}

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get autoremove -y && \
    apt-get clean -y

RUN echo "👋 Welcome to Codespaces! You are on a custom image defined in your devcontainer.json file.\n" > /usr/local/etc/vscode-dev-containers/first-run-notice.txt \
    && echo "🔍 To explore VS Code to its fullest, search using the Command Palette (Cmd/Ctrl + Shift + P)\n" >> /usr/local/etc/vscode-dev-containers/first-run-notice.txt \
    && echo "👋 Welcome to the NGSA-Java image\n" >> /usr/local/etc/vscode-dev-containers/first-run-notice.txt
