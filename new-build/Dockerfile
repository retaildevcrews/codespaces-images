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

FROM dind as kind

COPY local-scripts/*.sh /tmp/script-library/
RUN /bin/bash /tmp/script-library/kind-debian.sh && \
    rm -rf /tmp/script-library/


#######################
### Build kind-rust container from kind

FROM kind

ARG USERNAME=vscode

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update

RUN apt-get install -y pkg-config libssl-dev
RUN apt-get install -y python
RUN apt-get install -y clang
RUN apt-get install -y cmake

# install rust
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=1.52.1 \
    USER=${USERNAME}

RUN set -eux; \
    dpkgArch="$(dpkg --print-architecture)"; \
    case "${dpkgArch##*-}" in \
        amd64) rustArch='x86_64-unknown-linux-gnu'; rustupSha256='fb3a7425e3f10d51f0480ac3cdb3e725977955b2ba21c9bdac35309563b115e8' ;; \
        armhf) rustArch='armv7-unknown-linux-gnueabihf'; rustupSha256='f263e170da938888601a8e0bc822f8b40664ab067b390cf6c4fdb1d7c2d844e7' ;; \
        arm64) rustArch='aarch64-unknown-linux-gnu'; rustupSha256='de1dddd8213644cba48803118c7c16387838b4d53b901059e01729387679dd2a' ;; \
        i386) rustArch='i686-unknown-linux-gnu'; rustupSha256='66c03055119cecdfc20828c95429212ae5051372513f148342758bb5d0130997' ;; \
        *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
    esac; \
    url="https://static.rust-lang.org/rustup/archive/1.24.1/${rustArch}/rustup-init"; \
    wget "$url"; \
    echo "${rustupSha256} *rustup-init" | sha256sum -c -; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION --default-host ${rustArch}; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME;

RUN apt-get upgrade -y

RUN apt-get autoremove -y && \
    apt-get clean -y

WORKDIR /home/${USERNAME}
USER ${USERNAME}

# install cargo debug
RUN cargo install cargo-debug
RUN rustup update
RUN rustup component add rust-analysis && \
    rustup component add rust-src && \
    rustup component add rls
RUN rustup target add wasm32-unknown-unknown

#RUN curl -sL https://run.solo.io/wasme/install | sh

# install webv
RUN dotnet tool install -g webvalidate
