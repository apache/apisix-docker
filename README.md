## Docker distribution for Apache APISIX

**Docker images are not official ASF releases but provided for convenience. Recommended usage is always to build the source.**

1. install release version (Apache releases are beginning from version 0.9):
```
# Assign Apache release version number to variable `APISIX_VERSION`, for example: 1.2 . The latest version can be find at `https://github.com/apache/incubator-apisix/releases`

APISIX_VERSION=1.2
docker build -t apisix:${APISIX_VERSION}-alpine --build-arg APISIX_VERSION=${APISIX_VERSION} -f alpine/Dockerfile alpine
```

2. install master branch version, which has latest code(ONLY for the developer's convenience):
```
docker build -t apisix:master-alpine -f alpine/Dockerfile alpine
```


## Run with docker

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
--env ALLOW_NONE_AUTHENTICATION=yes bitnami/etcd:3.3.13-r80
```

> Note:
>
> 1. windows OS use absolute paths to hang in the configuration file.
> 2. e.g：windows dir path `E:\GitHub\docker-apisix `，configuration  file hang path is `-v /e/github/docker-apisix/example/etcd_conf/etcd.conf.yml:/opt/bitnami/etcd/conf/etcd.conf.yml`

### Run Apache APISIX server

You need etcd docker to work with Apache APISIX. You can refer to [the docker-compose example](example/README.md).

Or you can run APISIX with Docker directly（Docker name is test-api-gateway）:

Check or Modify etcd address to `http: //172.18.5.10:2379` in `pwd` / example / apisix_conf / config.yaml: /usr/local/apisix/conf/config.yaml

```
docker run --name test-api-gateway \
 -v `pwd`/example/apisix_conf/config.yaml:/usr/local/apisix/conf/config.yaml \
 -v `pwd`/example/apisix_log:/usr/local/apisix/logs  \
 -p 9080:9080 \
 -p 9443:9443 \
 --network apisix \
 --ip 172.18.5.11 \
 -d apache/apisix
```

> Note:
>
> 1. windows OS use absolute paths to hang in the configuration file and log dir.
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