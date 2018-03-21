CONTAINER_NAME ?= get-iplayer
PID ?=
TAG_NAME ?= riggerthegeek/get-iplayer

build:
	@echo "Building latest Docker images"
	docker build --file ./Dockerfile --tag ${TAG_NAME}:linux-amd64-latest .
	docker build --file ./Dockerfile.arm --tag ${TAG_NAME}:linux-arm-latest .
.PHONY: build

destroy:
	docker rm -f ${TAG_NAME}
.PHONY: destroy

run:
	docker run -it --rm -v="${PWD}/data:/opt/data" --name=${CONTAINER_NAME} ${TAG_NAME} ${PID}
.PHONY: run
