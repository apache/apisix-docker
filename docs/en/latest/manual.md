---
title: Deploy Apache APISIX with Docker
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

## Manual deploy apisix via docker

### Create a network `apisix`

```
docker network create \
  --driver=bridge \
  --subnet=172.18.0.0/16 \
  --ip-range=172.18.5.0/24 \
  --gateway=172.18.5.254 \
  apisix
```

### Run etcd server with `apisix` network

Specify ip `172.18.5.10`

```
docker run -it --name etcd-server \
-v `pwd`/example/etcd_conf/etcd.conf.yml:/opt/bitnami/etcd/conf/etcd.conf.yml \
-p 2379:2379 \
-p 2380:2380  \
--network apisix \
--ip 172.18.5.10 \
--env ALLOW_NONE_AUTHENTICATION=yes bitnami/etcd:3.4.9
```

> Note:
>
> 1. Windows OS use absolute paths to hang in the configuration file.
> 2. e.g：Windows dir path `E:\GitHub\docker-apisix`，configuration file hang path is `-v /e/github/docker-apisix/example/etcd_conf/etcd.conf.yml:/opt/bitnami/etcd/conf/etcd.conf.yml`

### Run Apache APISIX server

You need etcd docker to work with Apache APISIX. You can refer to [the docker-compose example](example.md).

Or you can run APISIX with Docker directly（Docker name is test-api-gateway）:

Check or Modify etcd address to `http: //172.18.5.10:2379` in `pwd` / example / apisix_conf / config.yaml: /usr/local/apisix/conf/config.yaml

```
docker run --name test-api-gateway \
 -v `pwd`/example/apisix_conf/config.yaml:/usr/local/apisix/conf/config.yaml \
 -v `pwd`/example/apisix_log:/usr/local/apisix/logs  \
 -p 9080:9080 \
 -p 9091:9091  \
 -p 9443:9443 \
 --network apisix \
 --ip 172.18.5.11 \
 -d apache/apisix
```

> Note:
>
> 1. Windows OS use absolute paths to hang in the configuration file and log dir.
>

### Have a test

Test with admin api

e.g. Get route list, should be return

```
curl http://127.0.0.1:9080/apisix/admin/routes/
...
{"node":{"createdIndex":4,"modifiedIndex":4,"key":"\/apisix\/routes","dir":true},"action":"get"}
```

### Clean

```
docker rm test-api-gateway
docker rm etcd-server
docker network rm apisix
```
