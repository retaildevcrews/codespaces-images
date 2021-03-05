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
