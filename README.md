**Docker images are not official ASF releases but provided for convenience. Recommended usage is always to build the source.**

## How To Build Image

**The master branch is for the verison of Apache APISIX 2.x . If you need a previous version, please build from the [v1.x](https://github.com/apache/apisix-docker/releases/tag/v1.x) tag.**

### Build an image from source

1. install release version:
```
# Assign Apache release version number to variable `APISIX_VERSION`, for example: 2.1 . The latest version can be find at `https://github.com/apache/apisix/releases`

export APISIX_VERSION=2.1
docker build -t apisix:${APISIX_VERSION}-alpine --build-arg APISIX_VERSION=${APISIX_VERSION} -f alpine/Dockerfile alpine
```

2. install master branch version, which has latest code(ONLY for the developer's convenience):
```
export APISIX_VERSION=master
docker build -t apisix:${APISIX_VERSION}-alpine --build-arg APISIX_VERSION=${APISIX_VERSION} -f alpine/Dockerfile alpine
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

