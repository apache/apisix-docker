**Docker images are not official ASF releases but provided for convenience. Recommended usage is always to build the source.**

## How To Build Image

**The master branch is for the version of Apache APISIX 2.x . If you need a previous version, please build from the [v1.x](https://github.com/apache/apisix-docker/releases/tag/v1.x) tag.**

### Build an image from source

1. install release version:
```
# Assign Apache release version number to variable `APISIX_VERSION`, for example: 2.2 . The latest version can be find at `https://github.com/apache/apisix/releases`

export APISIX_VERSION=2.2
docker build -t apisix:${APISIX_VERSION}-alpine --build-arg APISIX_VERSION=${APISIX_VERSION} -f alpine/Dockerfile alpine
```

2. install master branch version, which has latest code(ONLY for the developer's convenience):
```
export APISIX_VERSION=master
docker build -t apisix:${APISIX_VERSION}-alpine --build-arg APISIX_VERSION=${APISIX_VERSION} -f alpine/Dockerfile alpine
```

**Note:** For Chinese, the following command is always recommended. The additional build argument `ENABLE_PROXY=true` will enable proxy to definitely accelerate the progress.

```sh
$ docker build -t apisix:${APISIX_VERSION}-alpine --build-arg APISIX_VERSION=${APISIX_VERSION} --build-arg ENABLE_PROXY=true -f alpine/Dockerfile alpine
```

### Manual deploy apisix via docker

[Manual deploy](manual.md)

### QuickStart via docker-compose

**start all modules with docker-compose**

```
$ cd example
$ docker-compose -p docker-apisix up -d
```

You can refer to [the docker-compose example](example/README.md) for more try.

### Quick test with all dependencies in one Docker container

* All in one Docker container for Apache APISIX

```shell
$ docker build -t apache/apisix:whole -f ./all-in-one/apisix/Dockerfile .
$ docker run -v `pwd`/all-in-one/apisix/config.yaml:/usr/local/apisix/conf/config.yaml -p 9080:9080 -p 2379:2379 -d apache/apisix:whole
```

* All in one Docker container for Apache apisix-dashboard

**The latest version of `apisix-dashboard` is 2.3 and should be used with APISIX 2.2.**

```shell
$ docker build --build-arg APISIX_VERSION=2.2 --build-arg APISIX_DASHBOARD_VERSION=v2.3 -t apache/apisix-dashboard:whole -f ./all-in-one/apisix-dashboard/Dockerfile .
$ docker run -v `pwd`/all-in-one/apisix/config.yaml:/usr/local/apisix/conf/config.yaml -v `pwd`/all-in-one/apisix-dashboard/conf.yaml:/usr/local/apisix-dashboard/conf/conf.yaml -p 9080:9080 -p 2379:2379 -p 9000:9000 -d apache/apisix-dashboard:whole
```

Tips: If there is a port conflict, please modify the host port through `docker run -p`, e.g.

```shell
$ docker run -v `pwd`/all-in-one/apisix/config.yaml:/usr/local/apisix/conf/config.yaml -v `pwd`/all-in-one/apisix-dashboard/conf.yaml:/usr/local/apisix-dashboard/conf/conf.yaml -p 19080:9080 -p 12379:2379 -p 19000:9000 -d apache/apisix-dashboard:whole
```
