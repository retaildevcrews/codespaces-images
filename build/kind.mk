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
