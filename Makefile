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

APISIX_VERSION ?= 2.4
IMAGE_NAME = apache/apisix
IMAGE_TAR_NAME = apache_apisix

APISIX_DASHBOARD_VERSION ?= 2.4
DASHBOARD_IMAGE_NAME = apache/apisix-dashboard
DASHBOARD_IMAGE_TAR_NAME = apache_apisix_dashboard

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

### save-centos-tar:      tar apache/apisix:xx-centos image
save-centos-tar:
	mkdir -p package
	docker save -o ./package/$(IMAGE_TAR_NAME)_$(APISIX_VERSION)-centos.tar $(IMAGE_NAME):$(APISIX_VERSION)-centos

### save-alpine-tar:      tar apaceh/apisix:xx-alpine image
save-alpine-tar:
	mkdir -p package
	docker save -o ./package/$(IMAGE_TAR_NAME)_$(APISIX_VERSION)-alpine.tar $(IMAGE_NAME):$(APISIX_VERSION)-alpine

### build-dashboard:	Build apache/dashboard:tag image
build-dashboard:
	docker build -t $(DASHBOARD_IMAGE_NAME):$(APISIX_DASHBOARD_VERSION) -f ./dashboard/Dockerfile .

### save-dashboard-tar:      tar apaceh/apisix-dashboard:tag image
save-dashboard-tar:
	mkdir -p package
	docker save -o ./package/$(DASHBOARD_IMAGE_TAR_NAME)_$(APISIX_DASHBOARD_VERSION).tar $(DASHBOARD_IMAGE_NAME):$(APISIX_DASHBOARD_VERSION)

### help:             	  Show Makefile rules
help:
	@echo Makefile rules:
	@echo
	@grep -E '^### [-A-Za-z0-9_]+:' Makefile | sed 's/###/   /'
