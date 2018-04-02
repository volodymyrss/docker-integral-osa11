CONTAINER_NAME="10.194.169.76:443/integral-osa10"

build: 
	docker build -t $(CONTAINER_NAME) --build-arg uid=$(USER_ID) .

push: build
	docker push $(CONTAINER_NAME)

run: build
	docker run --privileged --entrypoint=bash -it $(CONTAINER_NAME)

