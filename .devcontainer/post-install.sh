#!/bin/sh

# add kubectl completion
mkdir -p ~/.local
cp .devcontainer/kubectl_completion ~/.local/kubectl_completion

# clone repos
cd ..
git clone https://github.com/retaildevcrews/ngsa
git clone https://github.com/retaildevcrews/ngsa-app
git clone https://github.com/retaildevcrews/loderunner

# create prometheus directory
sudo mkdir -p /prometheus
sudo chown -R 65534:65534 /prometheus

# copy grafana.db to /grafana
sudo mkdir -p /grafana
sudo  cp ngsa/IaC/DevCluster/grafanadata/grafana.db /grafana
sudo  chown -R 472:472 /grafana

# install kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.10.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/bin/kind

# install k9s
curl -Lo ./k9s.tar.gz https://github.com/derailed/k9s/releases/download/v0.24.2/k9s_Linux_x86_64.tar.gz
mkdir k9s
tar xvzf k9s.tar.gz -C ./k9s
sudo mv ./k9s/k9s /usr/bin/k9s
rm -rf k9s.tar.gz k9s

# update .bashrc
echo "" >> .bashrc
echo "export PATH=$PATH:$HOME/.local/bin" >> .bashrc

echo "alias k='kubectl'" >> .bashrc
echo "alias kga='kubectl get all'" >> .bashrc
echo "alias kgaa='kubectl get all --all-namespaces'" >> .bashrc
echo "alias kaf='kubectl apply -f'" >> .bashrc
echo "alias kdelf='kubectl delete -f'" >> .bashrc
echo "alias kl='kubectl logs'" >> .bashrc
echo "alias kccc='kubectl config current-context'" >> .bashrc
echo "alias kcgc='kubectl config get-contexts'" >> .bashrc

echo "export GO111MODULE=on" >> .bashrc
echo "alias ipconfig='ip -4 a show eth0 | grep inet | sed \"s/inet//g\" | sed \"s/ //g\" | cut -d / -f 1'" >> .bashrc
echo 'export PIP=$(ipconfig | tail -n 1)' >> .bashrc
echo 'source $HOME/.local/kubectl_completion' >> .bashrc
echo 'complete -F __start_kubectl k' >> .bashrc

export PATH=$PATH:$HOME/.local/bin
