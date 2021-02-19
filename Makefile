.PHONY: create delete deploy clean reset-prometheus reset-grafana all

reset-prometheus :
	sudo rm -rf /prometheus
	sudo mkdir -p /prometheus
	sudo chown -R 65534:65534 /prometheus

reset-grafana :
	sudo rm -rf /grafana
	sudo mkdir -p /grafana
	sudo cp -R deploy/grafanadata/grafana.db /grafana
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
	kubectl get po -A | grep "default\|monitoring"

clean :
	kubectl delete -f deploy/ngsa-memory
	kubectl delete -f deploy/loderunner
	kubectl delete ns monitoring
	kubectl get po -A

delete :
	kind delete cluster

loderunner :
	docker build ../loderunner -t ngsa-lr:local
	kind load docker-image ngsa-lr:local
	kubectl delete -f deploy/loderunner-local/loderunner.yaml

app :
	docker build ../ngsa-app -t ngsa-app:local
	kind load docker-image ngsa-app:local
	kubectl delete -f deploy/ngsa-local/ngsa-memory.yaml
	kubectl apply -f deploy/ngsa-local/ngsa-memory.yaml

all : delete create deploy
