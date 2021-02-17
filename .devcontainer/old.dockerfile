FROM ubuntu:focal

RUN apt-get update && \
    apt-get install -y apt-utils dialog lsb-release apt-transport-https curl ca-certificates && \
    apt-get install -y gnupg2 git build-essential httpie nano

RUN curl -Lo ./k9s.tar.gz https://github.com/derailed/k9s/releases/download/v0.24.2/k9s_Linux_x86_64.tar.gz && \
    mkdir k9s && \
    tar xvzf k9s.tar.gz -C ./k9s && \
    mv ./k9s/k9s /usr/bin/k9s && \
    rm -rf k9s && \
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.10.0/kind-linux-amd64 && \
    chmod +x ./kind && \
    mv ./kind /bin/kind && \
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
    curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | (OUT=$(apt-key add - 2>&1) || echo $OUT) && \
    echo "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list && \
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.asc.gpg && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/azure-cli.list

RUN apt-get update && \
    apt-get install -y kubectl docker-ce-cli azure-cli && \
    apt-get upgrade -y && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -g 1000 codespaces && \
    useradd -m -g codespaces -s /bin/bash -u 1000 codespaces

USER codespaces

RUN bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
