#!/bin/bash

echo "post-start start" >> ~/status

# this runs in background each time the container starts

# update the base docker images
docker pull mcr.microsoft.com/vscode/devcontainers/dotnet

echo "post-start complete" >> ~/status
