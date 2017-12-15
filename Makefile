CONTAINER_NAME="volodymyrsavchenko/docker-integral-osa:osa11"

build: 
	docker build -t $(CONTAINER_NAME) --build-arg uid=`id -u` .

push: build
	docker push $(CONTAINER_NAME)

run: build
	docker run --privileged --entrypoint=bash -it $(CONTAINER_NAME)
