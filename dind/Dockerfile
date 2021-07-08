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
RUN apt-get -y install --no-install-recommends httpie
RUN apt-get -y install --no-install-recommends gettext iputils-ping

# install oh-my-bash
RUN rm -rf /home/${USERNAME}/.oh-my-bash && \
    export OSH=/home/${USERNAME}/.oh-my-bash && \
    git clone --depth=1 https://github.com/ohmybash/oh-my-bash.git $OSH && \
    mv /home/${USERNAME}/.bashrc /home/${USERNAME}/.bashrc.pre-oh-my-bash && \
    cp $OSH/templates/bashrc.osh-template /home/${USERNAME}/.bashrc

# use scripts from: https://github.com/microsoft/vscode-dev-containers/tree/main/script-library
COPY script-library/*.sh /tmp/script-library/

RUN /bin/bash /tmp/script-library/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" && \
    /bin/bash /tmp/script-library/docker-in-docker-debian.sh "${ENABLE_NONROOT_DOCKER}" "${USERNAME}" "${USE_MOBY}" && \
    /bin/bash /tmp/script-library/kubectl-helm-debian.sh && \
    /bin/bash /tmp/script-library/azcli-debian.sh && \
    rm -rf /tmp/script-library/

VOLUME [ "/var/lib/docker" ]

# Setting the ENTRYPOINT to docker-init.sh will start up the Docker Engine 
# inside the container "overrideCommand": false is set in devcontainer.json. 
# The script will also execute CMD if you need to alter startup behaviors.
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]

#RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.asc.gpg && \
#    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/azure-cli.list && \
#    apt-get update

RUN apt-get install -y --no-install-recommends dotnet-sdk-5.0

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
    mkdir -p /home/${USERNAME}/.kube && \
    mkdir -p /home/${USERNAME}/.k9s && \
    mkdir -p /home/${USERNAME}/go/src && \
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
    echo "alias ipconfig='ip -4 a show eth0 | grep inet | sed \"s/inet//g\" | sed \"s/ //g\" | cut -d / -f 1'" >> /home/${USERNAME}/.bashrc && \
    echo "export GO111MODULE=on" >> /home/${USERNAME}/.bashrc && \
    echo 'export PIP=$(ipconfig | tail -n 1)' >> /home/${USERNAME}/.bashrc && \
    echo 'export PATH=$PATH:$HOME/.dotnet/tools' >> /home/${USERNAME}/.bashrc && \
    echo 'complete -F __start_kubectl k' >> /home/${USERNAME}/.bashrc && \
    kubectl completion bash > /etc/bash_completion.d/kubectl && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}


#######################
### Build kind container from Docker-in-Docker

FROM dind

### TODO - do we need this?
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key --keyring /etc/apt/trusted.gpg.d/docker.gpg add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update

RUN apt-get -y install --no-install-recommends containerd.io kubelet kubernetes-cni kubeadm

# install kind
RUN curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.10.0/kind-linux-amd64 && \
    chmod +x ./kind && \
    mv ./kind /usr/local/bin/kind

# install k3d
RUN wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash

# install k9s
RUN curl -Lo ./k9s.tar.gz https://github.com/derailed/k9s/releases/download/v0.24.2/k9s_Linux_x86_64.tar.gz && \
    mkdir k9s && \
    tar xvzf k9s.tar.gz -C ./k9s && \
    mv ./k9s/k9s /usr/local/bin/k9s && \
    rm -rf k9s.tar.gz k9s

# install fluxctl
RUN curl -L https://github.com/fluxcd/flux/releases/download/1.14.2/fluxctl_linux_amd64 -o /usr/local/bin/fluxctl && \
    chmod +x /usr/local/bin/fluxctl

#install istioctl
ENV ISTIO_VERSION=1.10.1 \
    ISTIO_HOME=/usr/local/istio
RUN curl -L https://istio.io/downloadIstio | sh -  && \
    mv istio-$ISTIO_VERSION $ISTIO_HOME

# create directories and set env vars
RUN mkdir -p /etc/containerd && \
    mkdir -p /etc/systemd/system/docker.service.d && \
    mkdir -p /etc/docker && \
    mkdir -p /prometheus && \
    mkdir -p /grafana && \
    chown -R 65534:65534 /prometheus && \
    chown -R 472:472 /grafana && \
    echo "export FLUX_FORWARD_NAMESPACE=flux-cd" >> /home/${USERNAME}/.bashrc && \
    echo "export ISTIO_VERSION=$ISTIO_VERSION" >> /home/akdc/.bashrc && \
    echo "export ISTIO_HOME=$ISTIO_HOME" >> /home/akdc/.bashrc && \
    echo 'export PATH=$ISTIO_HOME/bin:$PATH' >> /home/akdc/.bashrc
