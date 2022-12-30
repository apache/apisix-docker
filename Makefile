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

# Makefile basic env setting
.DEFAULT_GOAL := help
SHELL := bash


# APISIX ARGS
APISIX_VERSION ?= 3.1.0
MAX_APISIX_VERSION ?= 3.1.0
IMAGE_NAME = apache/apisix
IMAGE_TAR_NAME = apache_apisix

APISIX_DASHBOARD_VERSION ?= $(shell echo ${APISIX_DASHBOARD_VERSION:=2.15.0})
APISIX_DASHBOARD_IMAGE_NAME = apache/apisix-dashboard
APISIX_DASHBOARD_IMAGE_TAR_NAME = apache_apisix_dashboard


# Makefile ENV
ENV_OS_NAME                ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')
ENV_APISIX_TAR_NAME        ?= $(IMAGE_TAR_NAME)_$(APISIX_VERSION)
ENV_APISIX_IMAGE_TAG_NAME  ?= $(IMAGE_NAME):$(APISIX_VERSION)
ENV_DOCKER                 ?= docker


# Makefile basic extension function
_color_red    =\E[1;31m
_color_green  =\E[1;32m
_color_yellow =\E[1;33m
_color_blue   =\E[1;34m
_color_wipe   =\E[0m


define func_echo_status
	printf "[$(_color_blue) info $(_color_wipe)] %s\n" $(1)
endef


define func_echo_warn_status
	printf "[$(_color_yellow) info $(_color_wipe)] %s\n" $(1)
endef


define func_echo_success_status
	printf "[$(_color_green) info $(_color_wipe)] %s\n" $(1)
endef


# Makefile target
### build-on-centos : Build apache/apisix:xx-centos image
.PHONY: build-on-centos
build-on-centos:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_DOCKER) build -t $(ENV_APISIX_IMAGE_TAG_NAME)-centos -f ./centos/Dockerfile centos
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### build-on-debian-dev : Build apache/apisix:xx-debian-dev image
.PHONY: build-on-debian-dev
build-on-debian-dev:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_DOCKER) build -t $(ENV_APISIX_IMAGE_TAG_NAME)-debian-dev -f ./debian-dev/Dockerfile debian-dev
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### build-on-debian : Build apache/apisix:xx-debian image
.PHONY: build-on-debian
build-on-debian:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_DOCKER) build -t $(ENV_APISIX_IMAGE_TAG_NAME)-debian -f ./debian/Dockerfile debian
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### push-on-alpine : Push apache/apisix:dev image
.PHONY: push-multiarch-dev-on-debian
push-multiarch-dev-on-debian:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_DOCKER) buildx build --network=host --push \
		-t $(IMAGE_NAME):dev \
		--platform linux/amd64,linux/arm64 \
		-f ./debian-dev/Dockerfile debian-dev
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### push-multiarch-on-debian : Push apache/apisix:xx-debian image
.PHONY: push-multiarch-on-debian
push-multiarch-on-debian:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_DOCKER) buildx build --network=host --push \
		-t $(ENV_APISIX_IMAGE_TAG_NAME)-debian \
		--platform linux/amd64,linux/arm64 \
		-f ./debian/Dockerfile debian
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### push-multiarch-on-centos : Push apache/apisix:xx-centos image
.PHONY: push-multiarch-on-centos
push-multiarch-on-centos:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_DOCKER) buildx build --network=host --push \
		-t $(ENV_APISIX_IMAGE_TAG_NAME)-centos \
		--platform linux/amd64,linux/arm64 \
		-f ./centos/Dockerfile centos
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### push-multiarch-on-latest : Push apache/apisix:latest image
.PHONY: push-multiarch-on-latest
# Here we choose to check the max APISIX version instead of the patch version, so that
# we can release a patch version for a non-LTS version. For example, release a version
# to solve security issue.
push-multiarch-on-latest:
	@$(call func_echo_status, "$@ -> [ Start ]")
	@if [ "$(shell echo "$(APISIX_VERSION) $(MAX_APISIX_VERSION)" | tr " " "\n" | sort -rV | head -n 1)" == "$(APISIX_VERSION)" ]; then \
		$(ENV_DOCKER) buildx build --network=host --push \
			-t $(IMAGE_NAME):latest \
			--platform linux/amd64,linux/arm64 \
			-f ./debian/Dockerfile debian; \
	fi
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### build-all-in-one : Build All in one Docker container for Apache APISIX
.PHONY: build-all-in-one
build-all-in-one:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_DOCKER) build -t $(IMAGE_NAME):whole -f ./all-in-one/apisix/Dockerfile .
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### build-dashboard-all-in-one : Build All in one Docker container for Apache APISIX-dashboard
.PHONY: build-dashboard-all-in-one
build-dashboard-all-in-one:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_DOCKER) build -t $(APISIX_DASHBOARD_IMAGE_NAME):whole -f ./all-in-one/apisix-dashboard/Dockerfile .
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### save-centos-tar : tar apache/apisix:xx-centos image
.PHONY: save-centos-tar
save-centos-tar:
	@$(call func_echo_status, "$@ -> [ Start ]")
	mkdir -p package
	$(ENV_DOCKER) save -o ./package/$(ENV_APISIX_TAR_NAME)-centos.tar $(ENV_APISIX_IMAGE_TAG_NAME)-centos
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### save-debian-tar : tar apache/apisix:xx-debian image
.PHONY: save-debian-tar
save-debian-tar:
	@$(call func_echo_status, "$@ -> [ Start ]")
	mkdir -p package
	$(ENV_DOCKER) save -o ./package/$(ENV_APISIX_TAR_NAME)-debian.tar $(ENV_APISIX_IMAGE_TAG_NAME)-debian
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### build-dashboard-centos : Build apache/dashboard:tag image on centos
.PHONY: build-dashboard-centos
build-dashboard-centos:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_DOCKER) build -t $(APISIX_DASHBOARD_IMAGE_NAME):$(APISIX_DASHBOARD_VERSION) \
		--build-arg APISIX_DASHBOARD_TAG=v$(APISIX_DASHBOARD_VERSION) \
		-f ./dashboard/Dockerfile.centos .
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### build-dashboard-alpine : Build apache/dashboard:tag image on alpine
.PHONY: build-dashboard-alpine
build-dashboard-alpine:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_DOCKER) build -t $(APISIX_DASHBOARD_IMAGE_NAME):$(APISIX_DASHBOARD_VERSION) \
		--build-arg APISIX_DASHBOARD_TAG=v$(APISIX_DASHBOARD_VERSION) \
		-f ./dashboard/Dockerfile.alpine .
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### push-multiarch-dashboard : Build and push multiarch apache/dashboard:tag image
.PHONY: push-multiarch-dashboard
push-multiarch-dashboard:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(ENV_DOCKER) buildx build --push \
		-t $(APISIX_DASHBOARD_IMAGE_NAME):$(APISIX_DASHBOARD_VERSION)-alpine \
		--build-arg APISIX_DASHBOARD_TAG=v$(APISIX_DASHBOARD_VERSION) \
		--platform linux/amd64,linux/arm64 \
		-f ./dashboard/Dockerfile.alpine .
	$(ENV_DOCKER) buildx build --push \
		-t $(APISIX_DASHBOARD_IMAGE_NAME):$(APISIX_DASHBOARD_VERSION)-centos \
		--build-arg APISIX_DASHBOARD_TAG=v$(APISIX_DASHBOARD_VERSION) \
		--platform linux/amd64,linux/arm64 \
		-f ./dashboard/Dockerfile.centos .
	$(ENV_DOCKER) buildx build --push \
		-t $(APISIX_DASHBOARD_IMAGE_NAME):latest \
		--build-arg APISIX_DASHBOARD_TAG=v$(APISIX_DASHBOARD_VERSION) \
		--platform linux/amd64,linux/arm64 \
		-f ./dashboard/Dockerfile.centos .
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### save-dashboard-centos-tar : tar apache/apisix-dashboard:tag image
.PHONY: save-dashboard-centos-tar
save-dashboard-centos-tar:
	@$(call func_echo_status, "$@ -> [ Start ]")
	mkdir -p package
	$(ENV_DOCKER) save -o ./package/$(APISIX_DASHBOARD_IMAGE_TAR_NAME)_$(APISIX_DASHBOARD_VERSION)-centos.tar $(APISIX_DASHBOARD_IMAGE_NAME):$(APISIX_DASHBOARD_VERSION)
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### save-dashboard-alpine-tar : tar apache/apisix-dashboard:tag image
.PHONY: save-dashboard-alpine-tar
save-dashboard-alpine-tar:
	@$(call func_echo_status, "$@ -> [ Start ]")
	mkdir -p package
	$(ENV_DOCKER) save -o ./package/$(APISIX_DASHBOARD_IMAGE_TAR_NAME)_$(APISIX_DASHBOARD_VERSION)-alpine.tar $(APISIX_DASHBOARD_IMAGE_NAME):$(APISIX_DASHBOARD_VERSION)
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### help : Show Makefile rules
.PHONY: help
help:
	@$(call func_echo_success_status, "Makefile rules:")
	@echo
	@if [ '$(ENV_OS_NAME)' = 'darwin' ]; then \
		awk '{ if(match($$0, /^#{3}([^:]+):(.*)$$/)){ split($$0, res, ":"); gsub(/^#{3}[ ]*/, "", res[1]); _desc=$$0; gsub(/^#{3}([^:]+):[ \t]*/, "", _desc); printf("    make %-25s : %-10s\n", res[1], _desc) } }' Makefile; \
	else \
		awk '{ if(match($$0, /^\s*#{3}\s*([^:]+)\s*:\s*(.*)$$/, res)){ printf("    make %-25s : %-10s\n", res[1], res[2]) } }' Makefile; \
	fi
	@echo
