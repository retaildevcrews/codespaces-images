.PHONY: set-kind deploy clean reset-prometheus reset-grafana all

reset-prometheus :
	sudo rm -rf /prometheus
	sudo mkdir -p /prometheus
	sudo chown -R 65534:65534 /prometheus

reset-grafana :
	sudo rm -rf /grafana
	sudo mkdir -p /grafana
	sudo cp -R ~/ngsa/IaC/DevCluster/grafanadata/grafana.db /grafana
	sudo chown -R 472:472 /grafana

set-kind :
	kind create cluster --config .devcontainer/kind.yaml
	kubectl wait node --for condition=ready --all --timeout=60s

deploy :
	kubectl apply -f ../ngsa/IaC/DevCluster/ngsa-memory
	kubectl apply -f ../ngsa/IaC/DevCluster/prometheus
	kubectl apply -f ../ngsa/IaC/DevCluster/grafana
	kubectl wait pod ngsa-memory --for condition=ready --timeout=30s
	kubectl apply -f ../ngsa/IaC/DevCluster/loderunner/loderunner.yaml
	kubectl apply -f ../ngsa/IaC/DevCluster/grafana
	kubectl wait pod ngsa-memory --for condition=ready --timeout=30s
	kubectl wait pod -n monitoring --for condition=ready --all --timeout=30s

clean :
	kind delete clusters kind

all : clean set-kind deploy
