USER_ID?=$(shell id -u)
DOCKER_COMMIT=$(shell git describe --always)
OSA_VERSION?=$(shell curl https://www.isdc.unige.ch/~savchenk/gitlab-ci/integral/build/osa-build-tarball/CentOS_7.7.1908_x86_64/latest/latest/osa-version-ref.txt)
#OSA_VERSION_SHORT?=$(shell curl https://www.isdc.unige.ch/~savchenk/gitlab-ci/integral/build/osa-build-tarball/CentOS_7.5.1804_x86_64/latest/latest/osa-version-ref.txt | awk -F- '{print $$1,$$2,$$4}' OFS=-)

TAG="$(OSA_VERSION)-$(DOCKER_COMMIT)"
IMAGE="odahub/dda-interface:$(TAG)"

build: 
	docker build -t $(IMAGE) --build-arg uid=$(USER_ID) --build-arg OSA_VERSION=$(OSA_VERSION) --build-arg CONTAINER_COMMIT=$(DOCKER_COMMIT) .
	echo "built $(IMAGE)"
	echo $(TAG) > image-tag

push: build
	docker push $(IMAGE)

pull:
	docker pull $(IMAGE)

run-it: 
#build
	docker run --privileged --entrypoint=bash -it $(IMAGE)

run: build
	sh run.sh $(IMAGE)

