.PHONY: all clone set-kind clean post-kind deploy

clone :
	git clone https://github.com/retaildevcrews/ngsa ~/ngsa
	cd ~/ngsa/IaC/DevCluster

all: clean set-kind post-kind deploy

set-kind :
	kind create cluster --name akdc --config kind.yaml
	kubectl wait node --for condition=ready --all --timeout=60s

post-kind:
	$(eval KIND_ID:="$(shell docker ps | grep kindest/node | cut -f 1 -d ' ')")

	docker exec ${KIND_ID} mkdir -p /prometheus
	docker exec ${KIND_ID} chown -R 65534:65534 /prometheus

	docker exec ${KIND_ID} mkdir -p /grafana
	docker cp ~/ngsa/IaC/DevCluster/grafanadata/grafana.db ${KIND_ID}:/grafana
	docker exec ${KIND_ID} chown -R 472:472 /grafana

deploy:
	kubectl apply -f ~/ngsa/IaC/DevCluster/ngsa-memory
	kubectl apply -f ~/ngsa/IaC/DevCluster/prometheus
	kubectl apply -f ~/ngsa/IaC/DevCluster/loderunner/loderunner.yaml
	kubectl apply -f ~/ngsa/IaC/DevCluster/grafana

clean :
	kind delete clusters akdc
