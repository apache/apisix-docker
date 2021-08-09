**Docker images are not official ASF releases but provided for convenience. Recommended usage is always to build the source.**

## How To Build Image

**The master branch is for the version of Apache APISIX 2.x. If you need a previous version, please build from the [v1.x](https://github.com/apache/apisix-docker/releases/tag/v1.x) tag.**

### Build an image from source

1. Build from release version:
```sh
# Assign Apache release version number to variable `APISIX_VERSION`, for example: 2.6. The latest version can be find at `https://github.com/apache/apisix/releases`

export APISIX_VERSION=2.6
# alpine
$ make build-on-alpine

# centos
$ make build-on-centos
```

2. Build from master branch version, which has latest code(ONLY for the developer's convenience):
```sh
export APISIX_VERSION=master
# alpine
$ make build-on-alpine

# centos
$ make build-on-centos
```

3. Build from local code:
```sh
# To copy apisix into image, we need to include it in build context
$ cp -r <APISIX-PATH> ./apisix
$ APISIX_PATH=./apisix make build-on-alpine-local

# Might need root privilege if encounter "error checking context: 'can't stat'"
```

**Note:** For Chinese, the following command is always recommended. The additional build argument `ENABLE_PROXY=true` will enable proxy to definitely accelerate the progress.

```sh
$ make build-on-alpine-cn
```

### Manual deploy apisix via docker

[Manual deploy](docs/en/latest/manual.md)

### QuickStart via docker-compose

**start all modules with docker-compose**

```sh
$ cd example
$ docker-compose -p docker-apisix up -d
```

You can refer to [the docker-compose example](docs/en/latest/example.md) for more try.

### Quick test with all dependencies in one Docker container

* All in one Docker container for Apache APISIX

```shell
$ make build-all-in-one
$ docker run -v `pwd`/all-in-one/apisix/config.yaml:/usr/local/apisix/conf/config.yaml -p 9080:9080 -p 9091:9091 -p 2379:2379 -d apache/apisix:whole
```

* All in one Docker container for Apache apisix-dashboard

**The latest version of `apisix-dashboard` is 2.7 and should be used with APISIX 2.6.**

```shell
$ make build-dashboard
$ docker run -v `pwd`/all-in-one/apisix/config.yaml:/usr/local/apisix/conf/config.yaml -v `pwd`/all-in-one/apisix-dashboard/conf.yaml:/usr/local/apisix-dashboard/conf/conf.yaml -p 9080:9080 -p 9091:9091 -p 2379:2379 -p 9000:9000 -d apache/apisix-dashboard:whole
```

Tips: If there is a port conflict, please modify the host port through `docker run -p`, e.g.

```shell
$ docker run -v `pwd`/all-in-one/apisix/config.yaml:/usr/local/apisix/conf/config.yaml -v `pwd`/all-in-one/apisix-dashboard/conf.yaml:/usr/local/apisix-dashboard/conf/conf.yaml -p 19080:9080 -p 19091:9091 -p 12379:2379 -p 19000:9000 -d apache/apisix-dashboard:whole
```
