.PHONY: create delete deploy clean reset-prometheus reset-grafana all

reset-prometheus :
	sudo rm -rf /prometheus
	sudo mkdir -p /prometheus
	sudo chown -R 65534:65534 /prometheus

reset-grafana :
	sudo rm -rf /grafana
	sudo mkdir -p /grafana
	sudo cp -R ~/ngsa/IaC/DevCluster/grafanadata/grafana.db /grafana
	sudo chown -R 472:472 /grafana

create :
	kind create cluster --config .devcontainer/kind.yaml
	kubectl wait node --for condition=ready --all --timeout=60s

deploy :
	kubectl apply -f deploy/ngsa-memory
	kubectl apply -f deploy/prometheus
	kubectl apply -f deploy/grafana
	kubectl wait pod ngsa-memory --for condition=ready --timeout=30s
	kubectl apply -f deploy/loderunner
	kubectl wait pod loderunner --for condition=ready --timeout=30s
	kubectl wait pod -n monitoring --for condition=ready --all --timeout=30s

clean :
	kubectl delete -f deploy/ngsa-memory
	kubectl delete -f deploy/loderunner
	kubectl delete ns monitoring

delete :
	kind delete cluster

all : delete create deploy
