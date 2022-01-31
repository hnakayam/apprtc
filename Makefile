# note: build docker image using Ubuntu 18.04 or newer
# requires docker engine and required components
# see https://docs.docker.com/engine/install/ubuntu/

# replace REPO for your docker HUB image path or equivalents
# modify VERSION string to build new image
REPO=hnakayam/apprtc
VERSION=0.1

#
# build docker image
#

# default setting for docker build
# check /go/start.sh in docker instance for check result
BUILD_SERVER_IP=
BUILD_SERVER_OPTION=
BUILD_CERT_CN=

# Google App Engine local development server IP address and options (for image build and make image default)
# See https://cloud.google.com/appengine/docs/standard/python/tools/using-local-server
BUILD_SERVER_IP=--build-arg server_ip="0.0.0.0"
BUILD_SERVER_OPTION=--build-arg server_option="--enable_host_checking=false"

# Common Name for self signed certificate
BUILD_CERT_CN=--build-arg cert_cn=apprtc.japaneast.azurecontainer.io

build:
	@if docker image ls "$(REPO):$(VERSION)" | grep "$(REPO)" ; then echo "image already exist." ; else \
		docker build -t "$(REPO):$(VERSION)" $(BUILD_SERVER_IP) $(BUILD_SERVER_OPTION) $(BUILD_CERT_CN) . \
	; fi


# "docker image ls" will not set result code so use grep to set result code
ls:
	@if docker image ls "$(REPO):$(VERSION)" | grep "$(REPO)" ; then echo "image exist." ; else echo "image not exist." ; fi

#rm:
#	@docker image rm "$(REPO):$(VERSION)"

# docker push requres "docker login" beforhand. use docker hub account and password.
push:
	docker login && docker push "$(REPO):$(VERSION)"

#
# run docker imaghe
#

# default setting for docker run
RUNTIME_SERVER_IP=
RUNTIME_SERVER_OPTION=

# use containername for run/stop/attach/check
CONTAINERNAME=my_apprtc

# if we didn't cache docker image locally, download specified image from docker hub

# if you use "-ti" (interactive shell) option, you can detach shell by pressing Ctrl-P Ctrl-Q

# you can override SERVER_IP and SERVER_OPTION by setting docker --env option like below
#RUNTIME_SERVER_IP=--env SERVER_IP=0.0.0.0
#RUNTIME_SERVER_OPTION=--env SERVER_OPTION="--enable_host_checking=false"
#RUNTIME_SERVER_OPTION=--env SERVER_OPTION="--enable_host_checking=false --log_level debug"

# default network mode = bridge when --network option not specified in "docker run" command.

run:
	@if ! docker ps | grep -q "$(CONTAINERNAME)" ; then \
		sudo docker run --name="$(CONTAINERNAME)" \
		-p 443:443 -p 8089:8089 \
		$(RUNTIME_SERVER_IP) $(RUNTIME_SERVER_OPTION) --rm -ti $(REPO):$(VERSION) \
	; else echo "already running." ; fi

stop:
	@if docker ps | grep -q "$(CONTAINERNAME)" ; then docker stop "$(CONTAINERNAME)" ; else echo "not running." ; fi

attach:
	@if docker ps | grep -q "$(CONTAINERNAME)" ; then docker exec -it "$(CONTAINERNAME)" /bin/sh ; else echo "not running." ; fi

check:
	@if ! docker ps | grep -q "$(CONTAINERNAME)" ; then echo "not running." ; else echo "running." ; fi
