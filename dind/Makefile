.PHONY: help all scripts dind kind

help :
	@echo "Usage:"
	@echo "   make all        - build images images"
	@echo "   make scripts    - update scripts from vscode repo"
	@echo "   make kind       - build Kind image"
	@echo "   make dind       - build Docker-in-Docker image (dind)"


all : scripts kind dind

scripts :
	# Download scripts
	@curl -o script-library/azcli-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/azcli-debian.sh
	@curl -o script-library/common-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/common-debian.sh
	@curl -o script-library/docker-in-docker-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/docker-in-docker-debian.sh
	@curl -o script-library/kubectl-helm-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/kubectl-helm-debian.sh

kind :
	@docker build . -t kind

dind :
	@docker build . -t dind --target dind
