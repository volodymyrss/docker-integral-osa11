CONTAINER_NAME="admin.reproducible.online/integral-osa11-3"
USER_ID?=$(shell id -u)

build: 
	docker build -t $(CONTAINER_NAME) --build-arg uid=$(USER_ID) .

push: build
	docker push $(CONTAINER_NAME)

run-it: build
	docker run --privileged --entrypoint=bash -it $(CONTAINER_NAME)

run: build
	docker run $(CONTAINER_NAME)

