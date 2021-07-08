.PHONY: help all dind kind

help :
	@echo "Usage:"
	@echo "   make all              - build images images"
	@echo "   make kind             - build Kind image"
	@echo "   make create           - build Docker-in-Docker image (dind)"


all : kind dind

kind :
	docker build . -t kind

dind :
	docker build . -t dind --target dind
