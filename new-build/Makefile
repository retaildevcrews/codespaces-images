.PHONY: help all scripts dind kind kind-rust

help :
	@echo "Usage:"
	@echo "   make all        - build images images"
	@echo "   make scripts    - update scripts from vscode repo"
	@echo "   make dind       - build Docker-in-Docker image (dind)"
	@echo "   make kind       - build Kind image"
	@echo "   make kind-rust  - build Kind-rust image"


all : scripts kind-rust kind dind

scripts :
	# Download scripts
	@curl -o script-library/azcli-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/azcli-debian.sh
	@curl -o script-library/common-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/common-debian.sh
	@curl -o script-library/docker-in-docker-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/docker-in-docker-debian.sh
	@curl -o script-library/kubectl-helm-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/kubectl-helm-debian.sh

dind :
	@docker build . --target dind -t ghcr.io/retaildevcrews/dind:latest

kind :
	@docker build . --target kind -t ghcr.io/retaildevcrews/kind:beta

kind-rust :
	@docker build . -t ghcr.io/retaildevcrews/kind-rust:latest
