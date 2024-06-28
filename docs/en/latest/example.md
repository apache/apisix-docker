---
title: Example
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

**This example is used for functional verification and is not recommended for performance testing. For performance testing, please refer to [benchmark](https://github.com/apache/apisix#benchmark).**

### Run

```
docker-compose -d
```

### Configure

```
curl http://127.0.0.1:9180/apisix/admin/services/1 -H 'X-API-KEY: ${admin-key}' -X PUT -d '
{
    "upstream": {
        "type": "roundrobin",
        "nodes": {
            "web1:80": 1
        }
    }
}'

curl http://127.0.0.1:9180/apisix/admin/services/2 -H 'X-API-KEY: ${admin-key}' -X PUT -d '
{
    "upstream": {
        "type": "roundrobin",
        "nodes": {
            "web2:80": 1
        }
    }
}'

curl http://127.0.0.1:9180/apisix/admin/routes/12 -H 'X-API-KEY: ${admin-key}' -X PUT -d '
{
    "uri": "/*",
    "host": "web1.lvh.me",
    "service_id": "1"
}'

curl http://127.0.0.1:9180/apisix/admin/routes/22 -H 'X-API-KEY: ${admin-key}' -X PUT -d '
{
    "uri": "/*",
    "host": "web2.lvh.me",
    "service_id": "2"
}'

curl http://127.0.0.1:9180/apisix/admin/ssl/1 -H 'X-API-KEY: ${admin-key}' -X PUT -d "
{
    \"cert\": \"$( cat './mkcert/lvh.me+1.pem')\",
    \"key\": \"$( cat './mkcert/lvh.me+1-key.pem')\",
    \"sni\": \"lvh.me\"
}"

curl http://127.0.0.1:9180/apisix/admin/ssl/2 -H 'X-API-KEY: ${admin-key}' -X PUT -d "
{
    \"cert\": \"$( cat './mkcert/lvh.me+1.pem')\",
    \"key\": \"$( cat './mkcert/lvh.me+1-key.pem')\",
    \"sni\": \"*.lvh.me\"
}"
```

### Test

When testing subdomains, using localhost is not a good option. Due to this, lets use [http://lvh.me/](http://lvh.me/)
free service to resolve itself along with all subdomains to localhost.

```
curl http://web1.lvh.me:9080/hello -v # hello web1

curl http://web2.lvh.me:9080/hello -v # hello web2
```

```
curl https://web1.lvh.me:9443/ -v --cacert ./mkcert/rootCA.pem
```

### Clean

```
docker-compose down

sudo rm -rf etcd_data/member

rm -rf apisix_log/*.log
```
