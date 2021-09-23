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

## Build an image from source

**Docker images are not official ASF releases but provided for convenience. Recommended usage is always to build the source.**

1. install release version (Apache releases are beginning from version 0.9):
```
# Assign Apache release version number to variable `APISIX_VERSION`, for example: 2.2. The latest version can be find at `https://github.com/apache/apisix/releases`

export APISIX_VERSION=2.9
make build-on-alpine
```

2. install master branch version, which has latest code(ONLY for the developer's convenience):
```
export APISIX_VERSION=master
make build-on-alpine
```
