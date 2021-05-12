FROM mcr.microsoft.com/vscode/devcontainers/base:focal

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="false"
# [Option] Enable non-root Docker access in container
ARG ENABLE_NONROOT_DOCKER="true"
# [Option] Use the OSS Moby Engine instead of the licensed Docker Engine
ARG USE_MOBY="false"

# Install needed packages and setup non-root user. Use a separate RUN statement to add your
# own dependencies. A user of "automatic" attempts to reuse an user ID if one already exists.
ARG USERNAME=akdc
ARG USER_UID=4120
ARG USER_GID=$USER_UID

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update

RUN apt-get upgrade -y

RUN apt-get -y install --no-install-recommends apt-utils dialog
RUN apt-get -y install --no-install-recommends apt-transport-https ca-certificates
RUN apt-get -y install --no-install-recommends curl git
RUN apt-get -y install --no-install-recommends software-properties-common make

COPY library-scripts/*.sh /tmp/library-scripts/

RUN /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" \
    # Use Docker script from script library to set things up
    && /bin/bash /tmp/library-scripts/docker-in-docker-debian.sh "${ENABLE_NONROOT_DOCKER}" "${USERNAME}" "${USE_MOBY}" \
    # Clean up
    && rm -rf /tmp/library-scripts/

VOLUME [ "/var/lib/docker" ]

# Setting the ENTRYPOINT to docker-init.sh will start up the Docker Engine 
# inside the container "overrideCommand": false is set in devcontainer.json. 
# The script will also execute CMD if you need to alter startup behaviors.
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]

RUN apt-get -y install --no-install-recommends httpie

RUN apt-get -y install --no-install-recommends jq bash-completion

RUN wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.asc.gpg && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/azure-cli.list && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key --keyring /etc/apt/trusted.gpg.d/docker.gpg add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.asc.gpg && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/azure-cli.list && \
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update

RUN apt-get update

RUN apt-get install -y --no-install-recommends dotnet-sdk-5.0 bash-completion

RUN apt-get -y install --no-install-recommends containerd.io kubelet kubernetes-cni

RUN apt-get -y install --no-install-recommends kubectl kubeadm

RUN apt-get -y install --no-install-recommends azure-cli

# install kind, k9s, jp (jmespath), helm
RUN curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.10.0/kind-linux-amd64 && \
    chmod +x ./kind && \
    mv ./kind /usr/local/bin/kind && \
    wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash && \
    curl -Lo ./k9s.tar.gz https://github.com/derailed/k9s/releases/download/v0.24.2/k9s_Linux_x86_64.tar.gz && \
    mkdir k9s && \
    tar xvzf k9s.tar.gz -C ./k9s && \
    mv ./k9s/k9s /usr/local/bin/k9s && \
    rm -rf k9s.tar.gz k9s && \
    VERSION=$(curl -i https://github.com/jmespath/jp/releases/latest | grep "location: https://github.com/" | rev | cut -f 1 -d / | rev | sed 's/\r//') && \
    wget https://github.com/jmespath/jp/releases/download/$VERSION/jp-linux-amd64 -O /usr/local/bin/jp && \
    chmod +x /usr/local/bin/jp && \
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh && \
    chmod +x /usr/local/bin/helm && \
    rm get_helm.sh

# install other tools
RUN kubectl completion bash > /etc/bash_completion.d/kubectl && \
    mkdir -p /home/${USERNAME}/.ssh && \
    mkdir -p /home/${USERNAME}/.kube && \
    mkdir -p /home/${USERNAME}/bin && \
    mkdir -p /home/${USERNAME}/.local/bin && \
    mkdir -p /home/${USERNAME}/.k9s && \
    mkdir -p /home/${USERNAME}/go/src && \
    mkdir -p /home/${USERNAME}/.local && \
    mkdir -p /home/${USERNAME}/.dotnet/tools && \
    mkdir -p /etc/containerd && \
    mkdir -p /etc/systemd/system/docker.service.d && \
    mkdir -p /etc/docker && \
    mkdir -p /prometheus && \
    mkdir -p /grafana && \
    chown -R 65534:65534 /prometheus && \
    chown -R 472:472 /grafana && \
    echo "" >> /home/${USERNAME}/.bashrc && \
    echo "export PATH=$PATH:/home/$USERNAME/.local/bin:/home/$USERNAME/.dotnet/tools" >> /home/${USERNAME}/.bashrc && \
    echo "alias k='kubectl'" >> /home/${USERNAME}/.bashrc && \
    echo "alias kga='kubectl get all'" >> /home/${USERNAME}/.bashrc && \
    echo "alias kgaa='kubectl get all --all-namespaces'" >> /home/${USERNAME}/.bashrc && \
    echo "alias kaf='kubectl apply -f'" >> /home/${USERNAME}/.bashrc && \
    echo "alias kdelf='kubectl delete -f'" >> /home/${USERNAME}/.bashrc && \
    echo "alias kl='kubectl logs'" >> /home/${USERNAME}/.bashrc && \
    echo "alias kccc='kubectl config current-context'" >> /home/${USERNAME}/.bashrc && \
    echo "alias kcgc='kubectl config get-contexts'" >> /home/${USERNAME}/.bashrc && \
    echo "alias kj='kubectl exec -it jumpbox -- bash -l'" >> /home/${USERNAME}/.bashrc && \
    echo "alias kje='kubectl exec -it jumpbox -- '" >> /home/${USERNAME}/.bashrc && \
    echo "export GO111MODULE=on" >> /home/${USERNAME}/.bashrc && \
    echo "alias ipconfig='ip -4 a show eth0 | grep inet | sed \"s/inet//g\" | sed \"s/ //g\" | cut -d / -f 1'" >> /home/${USERNAME}/.bashrc && \
    echo 'export PIP=$(ipconfig | tail -n 1)' >> /home/${USERNAME}/.bashrc && \
    echo 'complete -F __start_kubectl k' >> /home/${USERNAME}/.bashrc && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# install flux cli
RUN curl -s https://fluxcd.io/install.sh | bash && \
    chmod +x /usr/local/bin/flux && \
    flux completion bash > /etc/bash_completion.d/flux

# install envsubst
RUN apt-get -y install --no-install-recommends gettext

RUN apt-get upgrade -y

RUN apt-get autoremove -y && \
    apt-get clean -y

