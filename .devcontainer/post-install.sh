#!/bin/sh
apt-get update
apt-get install -y apt-transport-https gnupg2 curl git ca-certificates lsb-release build-essential httpie nano
apt-get install -y kubectl docker-ce-cli
apt-get autoremove -y

curl -Lo ./k9s.tar.gz https://github.com/derailed/k9s/releases/download/v0.24.2/k9s_Linux_x86_64.tar.gz
mkdir k9s
tar xvzf k9s.tar.gz -C ./k9s
mv ./k9s/k9s /bin/k9s
rm ./k9s.tar.gz

curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.10.0/kind-linux-amd64
chmod +x ./kind
mv ./kind /bin/kind

# update .bashrc
echo "" >> ~/.bashrc
echo 'export PATH="$PATH:~/.dotnet/tools"' >> ~/.bashrc
echo "export AUTH_TYPE=CLI" >> ~/.bashrc
