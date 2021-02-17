.PHONY: clone pre-kind set-kind post-kind deploy clean all

clone :
	git clone https://github.com/retaildevcrews/ngsa ~/ngsa
	cd ~/ngsa/IaC/DevCluster

pre-kind :
	sudo mkdir -p /prometheus
	sudo chown -R 65534:65534 /prometheus

	sudo mkdir -p /grafana
	sudo cp -R ~/ngsa/IaC/DevCluster/grafanadata/grafana.db /grafana
	sudo chown -R 472:472 /grafana

set-kind :
	kind create cluster --name akdc --config kind.yaml
	kubectl wait node --for condition=ready --all --timeout=60s

post-kind :
	$(eval KIND_ID:="$(shell docker ps | grep kindest/node | cut -f 1 -d ' ')")

	docker exec ${KIND_ID} mkdir -p /prometheus
	docker exec ${KIND_ID} chown -R 65534:65534 /prometheus

	docker exec ${KIND_ID} mkdir -p /grafana
	docker cp ~/ngsa/IaC/DevCluster/grafanadata/grafana.db ${KIND_ID}:/grafana
	docker exec ${KIND_ID} chown -R 472:472 /grafana

deploy :
	kubectl apply -f ~/ngsa/IaC/DevCluster/ngsa-memory
	kubectl apply -f ~/ngsa/IaC/DevCluster/prometheus
	kubectl wait pod ngsa-memory --for condition=ready --timeout=30s
	kubectl apply -f ~/ngsa/IaC/DevCluster/loderunner/loderunner.yaml
	kubectl wait pod -n monitoring --for condition=ready --all --timeout=30s
	kubectl apply -f ~/ngsa/IaC/DevCluster/grafana
	kubectl wait pod -n monitoring --for condition=ready --all --timeout=30s

clean :
	kind delete clusters akdc

all : clean set-kind deploy
