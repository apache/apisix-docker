## Docker distribution for APISIX

You can install multiple versions of APISIX through docker:

1. install master branch version, which has latest code:
```
docker build -t apisix:master-alpine -f alpine/Dockerfile alpine
```

2. install release versions:
```
docker build -t apisix:0.8-alpine --build-arg APISIX_VERSION=0.8 -f alpine/Dockerfile alpine
```

## Run etcd server

```
docker run -it --name etcd-server \
-v ./example/etcd_conf/etcd.conf.yml:/opt/bitnami/etcd/conf/etcd.conf.yml \
-p 2379:2379 \
-p 2380:2380  \
--env ALLOW_NONE_AUTHENTICATION=yes bitnami/etcd:3.3.13-r80
```

> windows systems use absolute paths to hang in the configuration file
>
> eg：`-v /e/github/docker-apisix/example/etcd_conf/etcd.conf.yml:/opt/bitnami/etcd/conf/etcd.conf.yml`

## Run APISIX with etcd

You need etcd docker to work with APISIX. You can refer to
 [the docker-compose example](example/README.md).

Or you can run APISIX with Docker directly(Docker name is test-api-gateway):
```
docker run  --name test-api-gateway \
-v ./example/apisix_conf/config.yaml:/usr/local/apisix/conf/config.yaml \ 
-v ./example/apisix_log:/usr/local/apisix/logs  \
-p 8080:9080 \ 
-p 8083:9443 \
-d  iresty/apisix
```

NOTE: macOS not supports `host` network mode, so Linux is recommended.
