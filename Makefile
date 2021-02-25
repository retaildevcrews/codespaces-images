.PHONY: help all create delete deploy check clean app loderunner load-test reset-prometheus reset-grafana

help :
	@echo "Usage:"
	@echo "   make all              - create a cluster and deploy the apps"
	@echo "   make allk3d           - create a cluster with k3d and deploy the apps"
	@echo "   make create           - create a kind cluster"
	@echo "   make createk3d        - create a k3d cluster"
	@echo "   make delete           - delete the kind cluster"
	@echo "   make deletek3d        - delete the kind cluster"
	@echo "   make initdaprk8s      - inits dapr in the configured cluster"
	@echo "   make deploy           - deploy the apps to the cluster"
	@echo "   make check            - check the endpoints with curl"
	@echo "   make clean            - delete the apps from the cluster"
	@echo "   make app              - build and deploy a local app docker image"
	@echo "   make loderunner       - build and deploy a local LodeRunner docker image"
	@echo "   make load-test        - run a 60 second load test"
	@echo "   make reset-prometheus - reset the Prometheus volume (existing data is deleted)"
	@echo "   make reset-grafana    - reset the Grafana volume (existing data is deleted)"

all : delete create deploy check
allk3d : delete createk3d deploy check

delete :
	# delete the cluster (if exists)
	@kind delete cluster

deletek3d :
	# delete the cluster (if exists)
	@k3d cluster delete myclyster

initdaprk8s:
	@darp init --kubernetes

create :
	# create the cluster and wait for ready
	# this will fail harmlessly if the cluster exists
	# default cluster name is kind
	@kind create cluster --config .devcontainer/kind.yaml
	# wait for cluster to be ready
	@kubectl wait node --for condition=ready --all --timeout=60s

createk3d :
	# create the cluster and wait for ready
	# this will fail harmlessly if the cluster exists
	# default cluster name is kind
	@k3d cluster create mycluster --api-port 6443 --servers 1 --volume /prometheus:/prometheus --volume /grafana:/grafana --port 30088:30088@server[0] --port 30081:30081@server[0] --port 30080:30080@server[0] --port 32000:32000@server[0] --port 30000:30000@server[0]
	@k3d kubeconfig merge mycluster --kubeconfig-switch-context
	# wait for cluster to be ready
	@kubectl wait node --for condition=ready --all --timeout=60s
	@sleep 10
	@kubectl wait pod -n kube-system --for condition=ready --all --timeout=60s

deploy :
	# deploy the app
	# continue on most errors
	-kubectl apply -f deploy/ngsa-memory

	# deploy prometheus and grafana
	-kubectl apply -f deploy/prometheus
	-kubectl apply -f deploy/grafana

	# deploy fluent bit
	-kubectl create secret generic log-secrets --from-literal=WorkspaceId=dev --from-literal=SharedKey=dev
	-kubectl apply -f deploy/fluentbit/account.yaml
	-kubectl apply -f deploy/fluentbit/log.yaml
	-kubectl apply -f deploy/fluentbit/stdout-config.yaml
	-kubectl apply -f deploy/fluentbit/fluentbit-pod.yaml

	# deploy LodeRunner after the app starts
	@kubectl wait pod ngsa-memory --for condition=ready --timeout=30s
	-kubectl apply -f deploy/loderunner

	# wait for the pods to start
	@kubectl wait pod -n monitoring --for condition=ready --all --timeout=30s
	@kubectl wait pod fluentb --for condition=ready --timeout=30s
	@kubectl wait pod loderunner --for condition=ready --timeout=30s

	# display pod status
	@kubectl get po -A | grep "default\|monitoring"

check :
	# curl all of the endpoints
	@curl localhost:30080/version
	@echo "\n"
	@curl localhost:30088/version
	@echo "\n"
	@curl localhost:30000
	@curl localhost:32000

clean :
	# delete the deployment
	# continue on error
	-kubectl delete -f deploy/loderunner
	-kubectl delete -f deploy/ngsa-memory
	-kubectl delete ns monitoring
	-kubectl delete -f deploy/fluentbit/fluentbit-pod.yaml
	-kubectl delete secret log-secrets

	# show running pods
	@kubectl get po -A

app :
	# build the local image and load into kind
	docker build ../ngsa-app -t ngsa-app:local
	kind load docker-image ngsa-app:local

	# delete LodeRunner
	-kubectl delete -f deploy/loderunner

	# display the app version
	-http localhost:30080/version

	# delete/deploy the app
	-kubectl delete -f deploy/ngsa-memory
	kubectl apply -f deploy/ngsa-local

	# deploy LodeRunner after app starts
	@kubectl wait pod ngsa-memory --for condition=ready --timeout=30s
	kubectl apply -f deploy/loderunner
	@kubectl wait pod loderunner --for condition=ready --timeout=30s

	@kubectl get po

	# display the app version
	@http localhost:30080/version

loderunner :
	# build the local image and load into kind
	docker build ../loderunner -t ngsa-lr:local
	kind load docker-image ngsa-lr:local

	# display current version
	-http localhost:30088/version

	# delete / create LodeRunner
	-kubectl delete -f deploy/loderunner
	kubectl apply -f deploy/loderunner-local
	kubectl wait pod loderunner --for condition=ready --timeout=30s
	@kubectl get po

	# display the current version
	@http localhost:30088/version

load-test :
	# run a single test
	dotnet run -p ../loderunner/aspnetapp.csproj -- -s http://localhost:30080 -f baseline.json

	# run a 60 second test
	dotnet run -p ../loderunner/aspnetapp.csproj -- -s http://localhost:30080 -f baseline.json benchmark.json -r -l 1 --duration 60

reset-prometheus :
	# remove and create the /prometheus volume
	@sudo rm -rf /prometheus
	@sudo mkdir -p /prometheus
	@sudo chown -R 65534:65534 /prometheus

reset-grafana :
	# remove and copy the data to /grafana volume
	@sudo rm -rf /grafana
	@sudo mkdir -p /grafana
	@sudo cp -R deploy/grafanadata/grafana.db /grafana
	@sudo chown -R 472:472 /grafana
