CONTAINER_NAME="volodymyrsavchenko/docker-integral-osa:osa11"

build: 
	docker build -t $(CONTAINER_NAME) --build-arg uid=`id -u` .

push: build
	docker push $(CONTAINER_NAME)

run: build
	docker run --privileged --entrypoint=bash -it $(CONTAINER_NAME)

artifact: build
	package=`docker run --entrypoint bash volodymyrsavchenko/docker-integral-osa:osa11 -c 'cat package_list.txt'` && \
	echo "package $${package}" && \
        docker run --entrypoint bash volodymyrsavchenko/docker-integral-osa:osa11 -c 'cat `cat package_list.txt`' > ../artifacts/$${package}
