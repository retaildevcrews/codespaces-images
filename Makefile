.PHONY: help all scripts dind kind kind-rust java

help :
	@echo "Usage:"
	@echo "   make all        - build images images"
	@echo "   make scripts    - update scripts from vscode repo"
	@echo "   make dind       - build Docker-in-Docker image (dind)"
	@echo "   make kind       - build Kind image"
	@echo "   make kind-rust  - build Kind-rust image"
	@echo "   make java       - build java Codespaces image"


all : kind-rust kind-wasm kind dind java

scripts :
	@docker pull mcr.microsoft.com/vscode/devcontainers/dotnet

	# Download scripts from vscode-dev-containers repo
	@curl -o library-scripts/common-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/common-debian.sh
	@curl -o library-scripts/docker-in-docker-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/docker-in-docker-debian.sh
	@curl -o library-scripts/kubectl-helm-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/kubectl-helm-debian.sh
	@curl -o library-scripts/azcli-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/azcli-debian.sh
	@curl -o library-scripts/git-lfs-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/git-lfs-debian.sh
	@curl -o library-scripts/github-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/github-debian.sh
	@curl -o library-scripts/go-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/go-debian.sh
	@curl -o library-scripts/gradle-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/gradle-debian.sh
	@curl -o library-scripts/java-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/java-debian.sh
	@curl -o library-scripts/maven-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/maven-debian.sh
	@curl -o library-scripts/node-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/node-debian.sh
	@curl -o library-scripts/powershell-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/powershell-debian.sh
	@curl -o library-scripts/python-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/python-debian.sh
	@curl -o library-scripts/ruby-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/ruby-debian.sh
	@curl -o library-scripts/rust-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/rust-debian.sh
	@curl -o library-scripts/sshd-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/sshd-debian.sh
	@curl -o library-scripts/terraform-debian.sh -fsSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/terraform-debian.sh
	@curl -o library-scripts/dapr-debian.sh -fsSL https://raw.githubusercontent.com/dapr/cli/master/install/install.sh

dind : scripts
	@docker build . --target dind -t ghcr.io/retaildevcrews/dind:beta

kind : scripts
	@docker build . --target kind -t ghcr.io/retaildevcrews/kind:beta

kind-rust : scripts
	@docker build . --target kind-rust -t ghcr.io/retaildevcrews/kind-rust:beta

kind-wasm : scripts
	@docker build . --target kind-wasm -t ghcr.io/retaildevcrews/kind-wasm:beta

java : scripts
	@docker build . --target ngsa-java -t  ghcr.io/retaildevcrews/ngsa-java-codespaces:beta
