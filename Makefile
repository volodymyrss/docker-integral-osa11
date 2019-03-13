USER_ID?=$(shell id -u)
DOCKER_COMMIT=$(shell git describe --always)
OSA_VERSION?=$(shell curl https://www.isdc.unige.ch/~savchenk/gitlab-ci/integral/build/osa-build-tarball/CentOS_7.5.1804_x86_64/latest/latest/osa-version-ref.txt)
#OSA_VERSION_SHORT?=$(shell curl https://www.isdc.unige.ch/~savchenk/gitlab-ci/integral/build/osa-build-tarball/CentOS_7.5.1804_x86_64/latest/latest/osa-version-ref.txt | awk -F- '{print $$1,$$2,$$4}' OFS=-)
PRIVATE_GROUP?=""

CONTAINER_NAME="admin.reproducible.online/dda-worker-osa-$(OSA_VERSION)-g$(PRIVATE_GROUP)-$(DOCKER_COMMIT)"

build: 
	docker build -t $(CONTAINER_NAME) --build-arg uid=$(USER_ID) --build-arg OSA_VERSION=$(OSA_VERSION) --build-arg private_group=$(PRIVATE_GROUP) --build-arg dda_revision=$(DDA_REVISION) .
	echo "built $(CONTAINER_NAME)"

push: build
	docker push $(CONTAINER_NAME)

run-it: build
	docker run --privileged --entrypoint=bash -it $(CONTAINER_NAME)

run: build
	sh run.sh $(CONTAINER_NAME)

