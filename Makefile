.PHONY: help all create delete deploy clean app loderunner lode-test reset-prometheus reset-grafana

help :
	@echo "Usage:"
	@echo "   make all              - create a cluster and deploy the apps"
	@echo "   make create           - create a kind cluster"
	@echo "   make delete           - delete the kind cluster"
	@echo "   make deploy           - deploy the apps to the cluster"
	@echo "   make app              - build and deploy a local app docker image"
	@echo "   make loderunner       - build and deploy a local LodeRunner docker image"
	@echo "   make clean            - delete the apps from the cluster"
	@echo "   make reset-prometheus - reset the Prometheus volume (existing data is deleted)"
	@echo "   make reset-grafana    - reset the Grafana volume (existing data is deleted)"

all : delete create deploy

create :
	kind create cluster --config .devcontainer/kind.yaml
	kubectl wait node --for condition=ready --all --timeout=60s

delete :
	kind delete cluster

deploy :
	kubectl apply -f deploy/ngsa-memory
	kubectl apply -f deploy/prometheus
	kubectl apply -f deploy/grafana

	kubectl create secret generic log-secrets --from-literal=WorkspaceId=dev --from-literal=SharedKey=dev
	kubectl apply -f deploy/fluentbit/account.yaml
	kubectl apply -f deploy/fluentbit/log.yaml
	kubectl apply -f deploy/fluentbit/stdout-config.yaml
	kubectl apply -f deploy/fluentbit/fluentbit-pod.yaml

	kubectl wait pod ngsa-memory --for condition=ready --timeout=30s
	kubectl apply -f deploy/loderunner

	kubectl wait pod -n monitoring --for condition=ready --all --timeout=30s
	kubectl wait pod fluentb --for condition=ready --timeout=30s
	kubectl wait pod loderunner --for condition=ready --timeout=30s

	kubectl get po -A | grep "default\|monitoring"

clean :
	kubectl delete -f deploy/loderunner
	kubectl delete -f deploy/ngsa-memory
	kubectl delete ns monitoring
	kubectl get po -A

app :
	docker build ../ngsa-app -t ngsa-app:local
	kind load docker-image ngsa-app:local

	kubectl delete -f deploy/loderunner/loderunner.yaml

	http localhost:30080/version
	kubectl delete -f deploy/ngsa-local/ngsa-memory.yaml

	kubectl apply -f deploy/ngsa-local/ngsa-memory.yaml

	kubectl wait pod ngsa-memory --for condition=ready --timeout=30s
	kubectl apply -f deploy/loderunner/loderunner.yaml
	kubectl wait pod loderunner --for condition=ready --timeout=30s

	kubectl get po
	http localhost:30080/version

loderunner :
	docker build ../loderunner -t ngsa-lr:local
	kind load docker-image ngsa-lr:local
	http localhost:30088/version
	kubectl delete -f deploy/loderunner-local/loderunner.yaml
	kubectl apply -f deploy/loderunner-local/loderunner.yaml
	kubectl wait pod loderunner --for condition=ready --timeout=30s
	kubectl get po
	http localhost:30088/version

load-test :
	# run a single test
	dotnet run -p ../loderunner/aspnetapp.csproj -- -s http://localhost:30080 -f baseline.json

	# run a 60 second test
	dotnet run -p ../loderunner/aspnetapp.csproj -- -s http://localhost:30080 -f baseline.json benchmark.json -r -l 1 --duration 60

reset-prometheus :
	sudo rm -rf /prometheus
	sudo mkdir -p /prometheus
	sudo chown -R 65534:65534 /prometheus

reset-grafana :
	sudo rm -rf /grafana
	sudo mkdir -p /grafana
	sudo cp -R deploy/grafanadata/grafana.db /grafana
	sudo chown -R 472:472 /grafana
