#!/bin/sh

# add kubectl completion
mkdir -p ~/.local
cp .devcontainer/kubectl_completion ~/.local/kubectl_completion

# update .bashrc with helpful aliases
pushd ~
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

popd


### Application specific configuration
### Delete if reusing for other projects

# clone repos
pushd ..
sudo chown vscode:root .
git clone https://github.com/retaildevcrews/ngsa
git clone https://github.com/retaildevcrews/ngsa-app
git clone https://github.com/retaildevcrews/loderunner

popd

cp .devcontainer/workspace ../akdc.code-workspace

mkdir -p deploy
cd deploy
cp -R ../../ngsa/IaC/DevCluster/. .
mv loderunner/loderunner.yaml .
rm -rf loderunner
mkdir -p loderunner
mv loderunner.yaml loderunner
rm -rf kube-state-metrics
rm ngsa-memory/README.md
rm cheatsheet.txt
rm README.md

# create local yaml files
cp -R ngsa-memory/ ngsa-local
sed -i s/Always/Never/g ngsa-local/ngsa-memory.yaml
sed -i s@ghcr.io/retaildevcrews/ngsa-app:beta@ngsa-app:local@g ngsa-local/ngsa-memory.yaml

cp -R loderunner/ loderunner-local
sed -i s/Always/Never/g loderunner-local/loderunner.yaml
sed -i s@ghcr.io/retaildevcrews/ngsa-lr:beta@ngsa-lr:local@g loderunner-local/loderunner.yaml

# create prometheus directory
sudo mkdir -p /prometheus
sudo chown -R 65534:65534 /prometheus

# copy grafana.db to /grafana
sudo mkdir -p /grafana
sudo  cp grafanadata/grafana.db /grafana
sudo  chown -R 472:472 /grafana
