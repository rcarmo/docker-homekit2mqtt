export IMAGE_NAME=rcarmo/homekit2mqtt
export ARCH?=$(shell arch)
ifneq (,$(findstring arm,$(ARCH)))
export BASE=armv7/armhf-ubuntu:16.04
export ARCH=armhf
else
export BASE=ubuntu:16.04
endif
export MQTT_URL?=mqtt://127.0.0.1
export HOSTNAME?=homekit2mqtt
export DATA_FOLDER=$(HOME)/.config/homekit2mqtt
export VCS_REF=`git rev-parse --short HEAD`
export VCS_URL=https://github.com/rcarmo/docker-homekit2mqtt
export BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`

build: Dockerfile
	docker build --build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VCS_URL=$(VCS_URL) \
		--build-arg ARCH=$(ARCH) \
		--build-arg BASE=$(BASE) \
		-t $(IMAGE_NAME):$(ARCH) .

push:
	docker push $(IMAGE_NAME)

shell:
	docker run --net=lan -h $(HOSTNAME) -it $(IMAGE_NAME):$(ARCH) /bin/sh

test: 
	docker run -v $(DATA_FOLDER):/home/user/.config/homekit2mqtt \
		--net=host -h $(HOSTNAME) $(IMAGE_NAME):$(ARCH)

logs:
	docker logs $(HOSTNAME)

daemon: 
	-mkdir -p $(DATA_FOLDER)
	docker run -v $(DATA_FOLDER):/home/user/.config/homekit2mqtt \
		-v /var/run/dbus:/var/run/dbus \
		-e MQTT_URL=$(MQTT_URL) \
		--net=host --name $(HOSTNAME) -d --restart unless-stopped $(IMAGE_NAME):$(ARCH)

clean:
	-docker rm -v $$(docker ps -a -q -f status=exited)
	-docker rmi $$(docker images -q -f dangling=true)
	-docker rmi $$(docker images --format '{{.Repository}}:{{.Tag}}' | grep '$(IMAGE_NAME)')
