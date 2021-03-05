.PHONY : delete create

delete :
	# delete the cluster (if exists)
	@kind delete cluster

create :
	# create the cluster and wait for ready
	@# this will fail harmlessly if the cluster exists
	@# default cluster name is kind
	@kind create cluster --config build/kind.yaml
	# wait for cluster to be ready
	@kubectl wait node --for condition=ready --all --timeout=60s

app :
	# build the local image and load into kind
	docker build ../ngsa-app -t ngsa-app:local
	kind load docker-image ngsa-app:local

	# delete LodeRunner
	-kubectl delete -f deploy/loderunner --ignore-not-found=true

	# display the app version
	-http localhost:30080/version

	# delete/deploy the app
	-kubectl delete -f deploy/ngsa-memory --ignore-not-found=true
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
	-kubectl delete -f deploy/loderunner --ignore-not-found=true
	kubectl apply -f deploy/loderunner-local
	kubectl wait pod loderunner --for condition=ready --timeout=30s
	@kubectl get po

	# display the current version
	@http localhost:30088/version