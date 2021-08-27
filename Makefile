#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
default: help

APISIX_VERSION ?= 2.9
IMAGE_NAME = apache/apisix
IMAGE_TAR_NAME = apache_apisix

APISIX_DASHBOARD_VERSION ?= 2.7.1
APISIX_DASHBOARD_IMAGE_NAME = apache/apisix-dashboard
APISIX_DASHBOARD_IMAGE_TAR_NAME = apache_apisix_dashboard

### build-on-centos:      Build apache/apisix:xx-centos image
build-on-centos:
	docker build -t $(IMAGE_NAME):$(APISIX_VERSION)-centos -f ./centos/Dockerfile .

### build-on-alpine:      Build apache/apisix:xx-alpine image
build-on-alpine:
	docker build -t $(IMAGE_NAME):$(APISIX_VERSION)-alpine -f ./alpine/Dockerfile .

### build-on-alpine-local:      Build apache/apisix:xx-alpine-local image
# Actually it is not build on certain version but on local code
# Use this name (in the same patterns with others) for convenient CI
build-on-alpine-local:
	docker build -t $(IMAGE_NAME):$(APISIX_VERSION)-alpine-local --build-arg APISIX_PATH=${APISIX_PATH} -f ./alpine-local/Dockerfile .

### push-on-centos:       Push apache/apisix:xx-centos image
# centos not support multiarch since it reply on x86 rpm package
push-on-centos:
	docker push $(IMAGE_NAME):$(APISIX_VERSION)-centos
	docker build -t $(IMAGE_NAME):latest -f ./centos/Dockerfile .
	docker push $(IMAGE_NAME):latest

### push-on-alpine:       Push apache/apisix:xx-alpine image
push-multiarch-on-alpine:
	docker buildx build --push \
		-t $(IMAGE_NAME):$(APISIX_VERSION)-alpine \
		--platform linux/amd64,linux/arm64 \
		-f ./alpine/Dockerfile .

### build-on-alpine-cn:		 Build apache/apisix:xx-alpine image (for chinese)
build-on-alpine-cn:
	docker build -t $(IMAGE_NAME):${APISIX_VERSION}-alpine --build-arg APISIX_VERSION=${APISIX_VERSION} --build-arg ENABLE_PROXY=true -f alpine/Dockerfile alpine

### build-all-in-one:		 Build All in one Docker container for Apache APISIX
build-all-in-one:
	docker build -t $(IMAGE_NAME):whole -f ./all-in-one/apisix/Dockerfile .

### save-centos-tar:      tar apache/apisix:xx-centos image
save-centos-tar:
	mkdir -p package
	docker save -o ./package/$(IMAGE_TAR_NAME)_$(APISIX_VERSION)-centos.tar $(IMAGE_NAME):$(APISIX_VERSION)-centos

### save-alpine-tar:      tar apache/apisix:xx-alpine image
save-alpine-tar:
	mkdir -p package
	docker save -o ./package/$(IMAGE_TAR_NAME)_$(APISIX_VERSION)-alpine.tar $(IMAGE_NAME):$(APISIX_VERSION)-alpine

### build-dashboard:	Build apache/dashboard:tag image
build-dashboard:
	docker build -t $(APISIX_DASHBOARD_IMAGE_NAME):$(APISIX_DASHBOARD_VERSION) -f ./dashboard/Dockerfile .

### push-dashboard:     Push apache/dashboard:tag image
push-dashboard:
	docker push $(APISIX_DASHBOARD_IMAGE_NAME):$(APISIX_DASHBOARD_VERSION)
	docker build -t $(APISIX_DASHBOARD_IMAGE_NAME):latest -f ./dashboard/Dockerfile .
	docker push $(APISIX_DASHBOARD_IMAGE_NAME):latest

### save-dashboard-tar:      tar apache/apisix-dashboard:tag image
save-dashboard-tar:
	mkdir -p package
	docker save -o ./package/$(APISIX_DASHBOARD_IMAGE_TAR_NAME)_$(APISIX_DASHBOARD_VERSION).tar $(APISIX_DASHBOARD_IMAGE_NAME):$(APISIX_DASHBOARD_VERSION)

### help:             	  Show Makefile rules
help:
	@echo Makefile rules:
	@echo
	@grep -E '^### [-A-Za-z0-9_]+:' Makefile | sed 's/###/   /'
