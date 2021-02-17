#!/bin/sh
apt-get update
apt-get install -y apt-transport-https gnupg2 curl git ca-certificates lsb-release build-essential httpie nano

cd ~
echo "k9s" >> status
curl -Lo ./k9s.tar.gz https://github.com/derailed/k9s/releases/download/v0.24.2/k9s_Linux_x86_64.tar.gz
mkdir k9s
tar xvzf k9s.tar.gz -C ./k9s
mv ./k9s/k9s .local/bin/k9s
llrm ./k9s.tar.gz
rm -rf k9s

echo "kind" >> status
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.10.0/kind-linux-amd64
chmod +x ./kind
mv ./kind .local/bin/kind

echo "clone" >> status
git clone https://github.com/retaildevcrews/ngsa

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
echo 'source /usr/share/bash-completion/bash_completion' >> .bashrc
echo 'source <(kubectl completion bash)' >> .bashrc
echo 'complete -F __start_kubectl k' >> .bashrc

export PATH=$PATH:$HOME/.local/bin

echo "done" >> status