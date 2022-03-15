**Docker images are not official ASF releases but provided for convenience. Recommended usage is always to build the source.**

## How To Build Image

**The master branch is for the version of Apache APISIX 2.x. If you need a previous version, please build from the [v1.x](https://github.com/apache/apisix-docker/releases/tag/v1.x) tag.**

### Build an image from source

1. Build from release version:
```sh
# Assign Apache release version to variable `APISIX_VERSION`, for example: 2.9.
# The latest release version can be find at `https://github.com/apache/apisix/releases`

export APISIX_VERSION=2.9

# build alpine based image
make build-on-alpine

# build centos based image
make build-on-centos
```

2. Build from master branch version, which has latest code(ONLY for the developer's convenience):
```sh
export APISIX_VERSION=master

# build alpine based image
make build-on-alpine

# build centos based image
make build-on-centos
```

3. Build from local code:
```sh
# To copy apisix into image, we need to include it in build context
cp -r <APISIX-PATH> ./apisix

export APISIX_PATH=./apisix
make build-on-alpine-local

# Might need root privilege if encounter "error checking context: 'can't start'"
```

**Note:** For Chinese, the following command is always recommended. The additional build argument `ENABLE_PROXY=true` will enable proxy to definitely accelerate the progress.

```sh
$ make build-on-alpine-cn
```

4. Build apisix-dashboard from release version:

```sh
# Assign the release version of Apache APISIX Dashboard to variable `APISIX_DASHBOARD_VERSION`, for example: 2.10.
# The latest release version can be found at `https://github.com/apache/apisix-dashboard/releases`

export APISIX_DASHBOARD_VERSION=2.10

# build alpine based image
make build-dashboard-alpine

# build centos based image
make build-dashboard-centos
```

### Manual deploy apisix via docker

[Manual deploy](https://github.com/apache/apisix-docker/blob/master/docs/en/latest/manual.md)

### QuickStart via docker-compose

**start all modules with docker-compose**

```sh
cd example
docker-compose -p docker-apisix up -d
```

You can refer to [the docker-compose example](https://github.com/apache/apisix-docker/blob/master/docs/en/latest/example.md) for more try.

### Quick test with all dependencies in one Docker container

* All in one Docker container for Apache APISIX

```sh
make build-all-in-one

# launch APISIX container
docker run -d \
-p 9080:9080 -p 9091:9091 -p 2379:2379 \
-v `pwd`/all-in-one/apisix/config.yaml:/usr/local/apisix/conf/config.yaml \
apache/apisix:whole
```

* All in one Docker container for Apache apisix-dashboard

**The latest version of `apisix-dashboard` is 2.10 and can be used with APISIX 2.11.**

```sh
make build-dashboard-all-in-one

# launch APISIX-dashboard container
docker run -d \
-p 9080:9080 -p 9091:9091 -p 2379:2379 -p 9000:9000 \
-v `pwd`/all-in-one/apisix/config.yaml:/usr/local/apisix/conf/config.yaml \
-v `pwd`/all-in-one/apisix-dashboard/conf.yaml:/usr/local/apisix-dashboard/conf/conf.yaml \
apache/apisix-dashboard:whole
```

Tips: If there is a port conflict, please modify the host port through `docker run -p`, e.g.

```sh
# launch APISIX-AIO container
docker run -d \
-p 19080:9080 -p 19091:9091 -p 12379:2379 -p 19000:9000 \
-v `pwd`/all-in-one/apisix/config.yaml:/usr/local/apisix/conf/config.yaml \
-v `pwd`/all-in-one/apisix-dashboard/conf.yaml:/usr/local/apisix-dashboard/conf/conf.yaml \
apache/apisix-dashboard:whole
```

### Note

**Prometheus**

Apache APISIX expose prometheus metrics port on 9091, and you need to expose it to `0.0.0.0` instead of the default `127.0.0.1` to make it accessible outside docker. You could achieve it with adding the following to your `config.yaml`.

```shell
plugin_attr:
  prometheus:
    export_addr:
      ip: "0.0.0.0"
      port: 9091
```

**APISIX-Dev Image**

At `0:00 UTC` every day, the APISIX `master` code will be automatically built and synchronized to the Docker Hub repository. You can pull the latest master branch image in the following ways.

```bash
docker pull apache/apisix:dev
```
