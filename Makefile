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

APISIX_VERSION ?= 2.3
IMAGE_NAME = apache/apisix
IMAGE_TAR_NAME = apache_apisix

### build-on-centos:      Build apaceh/apisix:xx-centos image
build-on-centos:
	docker build -t $(IMAGE_NAME):$(APISIX_VERSION)-centos -f ./centos/Dockerfile .

### build-on-alpine:      Build apaceh/apisix:xx-alpine image
build-on-alpine:
	docker build -t $(IMAGE_NAME):$(APISIX_VERSION)-alpine -f ./alpine/Dockerfile .

### save-centos-tar:      tar apaceh/apisix:xx-centos image
save-centos-tar:
	mkdir -p package
	docker save -o ./package/$(IMAGE_TAR_NAME)_$(APISIX_VERSION)-centos.tar $(IMAGE_NAME):$(APISIX_VERSION)-centos

### save-alpine-tar:      tar apaceh/apisix:xx-alpine image
save-alpine-tar:
	mkdir -p package
	docker save -o ./package/$(IMAGE_TAR_NAME)_$(APISIX_VERSION)-alpine.tar $(IMAGE_NAME):$(APISIX_VERSION)-alpine

### help:             	  Show Makefile rules
help:
	@echo Makefile rules:
	@echo
	@grep -E '^### [-A-Za-z0-9_]+:' Makefile | sed 's/###/   /'
