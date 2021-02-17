.PHONY: clone set-kind clean

clone :
	git clone https://github.com/retaildevcrews/ngsa ~/ngsa
	cd ~/ngsa/IaC/DevCluster

set-kind :
	kind create cluster --name akdc --config kind.yaml

clean :
	kind delete clusters adkc
