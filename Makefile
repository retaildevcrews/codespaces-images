.PHONY: help all scripts dind kind kind-rust

help :
	@echo "Usage:"
	@echo "   make all        - build images images"
	@echo "   make scripts    - update scripts from vscode repo"
	@echo "   make dind       - build Docker-in-Docker image (dind)"
	@echo "   make kind       - build Kind image"
	@echo "   make kind-rust  - build Kind-rust image"


all : kind-rust kind dind

scripts :
	@docker pull mcr.microsoft.com/vscode/devcontainers/dotnet

	# Download scripts
	@curl -o .devcontainer/library-scripts/common-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/common-debian.sh
	@curl -o .devcontainer/library-scripts/docker-in-docker-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/docker-in-docker-debian.sh
	@curl -o .devcontainer/library-scripts/kubectl-helm-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/kubectl-helm-debian.sh
	@curl -o .devcontainer/library-scripts/azcli-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/azcli-debian.sh
	@curl -o .devcontainer/library-scripts/git-lfs-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/git-lfs-debian.sh
	@curl -o .devcontainer/library-scripts/github-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/github-debian.sh
	@curl -o .devcontainer/library-scripts/go-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/go-debian.sh
	@curl -o .devcontainer/library-scripts/gradle-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/gradle-debian.sh
	@curl -o .devcontainer/library-scripts/java-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/java-debian.sh
	@curl -o .devcontainer/library-scripts/maven-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/maven-debian.sh
	@curl -o .devcontainer/library-scripts/node-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/node-debian.sh
	@curl -o .devcontainer/library-scripts/powershell-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/powershell-debian.sh
	@curl -o .devcontainer/library-scripts/python-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/python-debian.sh
	@curl -o .devcontainer/library-scripts/ruby-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/ruby-debian.sh
	@curl -o .devcontainer/library-scripts/rust-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/rust-debian.sh
	@curl -o .devcontainer/library-scripts/sshd-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/sshd-debian.sh
	@curl -o .devcontainer/library-scripts/terraform-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/terraform-debian.sh

dind : scripts
	@docker build . --target dind -t ghcr.io/retaildevcrews/dind:latest

kind : scripts
	@docker build . --target kind -t ghcr.io/retaildevcrews/kind:latest

kind-rust : scripts
	@docker build . -t ghcr.io/retaildevcrews/kind-rust:latest
