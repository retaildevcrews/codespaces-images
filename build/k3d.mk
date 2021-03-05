.PHONY : delete create

delete :
	# delete the cluster (if exists)
	@k3d cluster delete

create :
	@# create the cluster and wait for ready
	@# this will fail harmlessly if the cluster exists
	@# default cluster name is kind
	@k3d cluster create --config build/k3d.yaml
	# wait for cluster to be ready
	@kubectl wait node --for condition=ready --all --timeout=60s
	@kubectl wait job helm-install-traefik -n kube-system --for condition=complete --timeout=60s
	@kubectl wait pod -n kube-system --for condition=ready -l app=local-path-provisioner  --timeout=60s
	@kubectl wait pod -n kube-system --for condition=ready -l k8s-app=metrics-server  --timeout=60s
	@kubectl wait pod -n kube-system --for condition=ready -l k8s-app=kube-dns  --timeout=60s
	@kubectl wait pod -n kube-system --for condition=ready -l app=svclb-traefik  --timeout=60s
	@kubectl wait pod -n kube-system --for condition=ready -l app=traefik  --timeout=60s

app :
	# build the local image and load into k3d
	docker build ../ngsa-app -t ngsa-app:local
	k3d image import ngsa-app:local

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
	# build the local image and load into k3d
	docker build ../loderunner -t ngsa-lr:local
	k3d image import ngsa-lr:local

	# display current version
	-http localhost:30088/version

	# delete / create LodeRunner
	-kubectl delete -f deploy/loderunner --ignore-not-found=true
	kubectl apply -f deploy/loderunner-local
	kubectl wait pod loderunner --for condition=ready --timeout=30s
	@kubectl get po

	# display the current version
	@http localhost:30088/version