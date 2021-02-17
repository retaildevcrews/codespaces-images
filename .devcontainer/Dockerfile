FROM mcr.microsoft.com/vscode/devcontainers/base:focal

WORKDIR /home/vscode

RUN groupadd -g 800 docker && \
    usermod -a -G docker vscode

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y apt-utils dialog lsb-release apt-transport-https curl ca-certificates

RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y gnupg2 git build-essential httpie nano

RUN curl -Lo k9s.tar.gz https://github.com/derailed/k9s/releases/download/v0.24.2/k9s_Linux_x86_64.tar.gz && \
    mkdir k9s && \
    tar xvzf k9s.tar.gz -C k9s && \
    mv k9s/k9s /usr/bin/k9s && \
    rm -rf k9s && \
    rm k9s.tar.gz

RUN curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.10.0/kind-linux-amd64 && \
    chmod +x ./kind && \
    mv ./kind /usr/bin/kind

RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
    curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | (OUT=$(apt-key add - 2>&1) || echo $OUT) && \
    echo "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list && \
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.asc.gpg && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/azure-cli.list && \
    DEBIAN_FRONTEND=noninteractive && \
    apt-get update

#RUN DEBIAN_FRONTEND=noninteractive && \
#    apt-get install -y azure-cli

RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y docker-ce-cli

RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y kubectl

RUN apt-get upgrade -y && \
    apt-get autoremove -y

USER vscode
