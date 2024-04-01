---
title: Build an image from the source codes
---

<!--
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
-->

**Docker images are not official ASF releases but provided for convenience. Recommended usage is always to build the source.**

## Clone the repository

Clone the [apisix-docker](https://github.com/apache/apisix-docker) repository and navigate into the project directory:

```shell
git clone https://github.com/apache/apisix-docker.git
cd apisix-docker
```

## Build a Docker image

Choose one of the following approaches to build a Docker image based on your requirements.

### Build an image from a release
  
Find an APISIX [release version](https://github.com/apache/apisix/releases) to build an image of.

Build a Docker image from the release:

```shell
APISIX_VERSION=3.9.0    # specify release version
DISTRO=debian           # debian, redhat
make build-on-$DISTRO
```

### Build an image from master branch

This is provided for developer's convenience.

Build a Docker image from the master branch:

```shell
APISIX_VERSION=master   # master branch
DISTRO=debian           # debian, redhat
make build-on-$DISTRO
```

### Build an image from locally customized/patched source code

Build a Docker image from locally customized/patched source code with this [Dockerfile](https://github.com/apache/apisix-docker/blob/master/debian-dev/Dockerfile.local):

```shell
docker build -t apisix-dev-local -f /path/to/debian-dev/Dockerfile.local  .
```

## Check Docker image

Check the built Docker images:

```shell
docker images
```

If the image was built successfully, you should see the image listed, similar to the following:

```text
REPOSITORY        TAG            IMAGE ID       CREATED              SIZE
apache/apisix     3.5.0-debian   5c3b6ffdef06   About a minute ago   337MB
```
