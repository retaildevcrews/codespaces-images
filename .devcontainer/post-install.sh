#!/bin/sh

# clone repos
pushd ..
git clone https://github.com/retaildevcrews/ngsa
git clone https://github.com/retaildevcrews/ngsa-app
git clone https://github.com/retaildevcrews/loderunner

popd

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

# copy grafana.db to /grafana
sudo mkdir -p /grafana
sudo  cp grafanadata/grafana.db /grafana
sudo  chown -R 472:472 /grafana
