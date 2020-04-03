## Docker distribution for Apache APISIX

**Docker images are not official ASF releases but provided for convenience. Recommended usage is always to build the source.**

1. install release version (Apache releases are beginning from version 0.9):
```
docker build -t apisix:1.1-alpine --build-arg APISIX_VERSION=1.1 -f alpine/Dockerfile alpine
```

2. install master branch version, which has latest code(ONLY for the developer's convenience):
```
docker build -t apisix:master-alpine -f alpine/Dockerfile alpine
```


## Run etcd server

```
docker run -it --name etcd-server \
-v `pwd`/example/etcd_conf/etcd.conf.yml:/opt/bitnami/etcd/conf/etcd.conf.yml \
-p 2379:2379 \
-p 2380:2380  \
--env ALLOW_NONE_AUTHENTICATION=yes bitnami/etcd:3.3.13-r80
```

> Note:
>
> 1. windows OS use absolute paths to hang in the configuration file.
> 2. e.g：windows dir path `E:\GitHub\docker-apisix `，configuration  file hang path is `-v /e/github/docker-apisix/example/etcd_conf/etcd.conf.yml:/opt/bitnami/etcd/conf/etcd.conf.yml`

## Run Apache APISIX server

You need etcd docker to work with Apache APISIX. You can refer to [the docker-compose example](example/README.md).

Or you can run APISIX with Docker directly（Docker name is test-api-gateway）:
```
docker run --name test-api-gateway \
-v `pwd`/example/apisix_conf/config.yaml:/usr/local/apisix/conf/config.yaml \
-v `pwd`/example/apisix_log:/usr/local/apisix/logs  \
-p 8080:9080 \
-p 8083:9443 \
-d apache/apisix
```

> Note:
>
> 1. mac OS not supports `host` network mode, so Linux is recommended.
>
> 2. windows OS use absolute paths to hang in the configuration file and log dir.
>
