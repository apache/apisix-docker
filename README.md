## Summary
This repo contains docker images for APISIX and APISIX dashboard. It also includes useful commands to use, build, and save the images and an example that illustrates how to start these services with docker-compose.

**Note**: Docker images are not official ASF releases but provided for convenience. Recommended usage is always to build the source.

## How To Build Images

The repo contains the following images:

- `/alpine/Dockerfile` builds APISIX on alpine.

- `/centos/Dockerfile`builds APISIX on centos.

- `/dashboard` contains two docker files - `Dockerfile.alpine` and `Dockerfile.centos`, which build APISIX dashboard on alpine and centos respectively.

You can build these images as follows:

**Note**: The master branch is for the version of Apache APISIX 2.x. If you need a previous version, please build from the [v1.x](https://github.com/apache/apisix-docker/releases/tag/v1.x) tag.

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

## Run With Docker-compose

The following example illustrates how to run APISIX and APISIX dashboard with docker-compose. If you want to manually deploy services, please refer to [this guide](https://github.com/apache/apisix-docker/blob/master/docs/en/latest/manual.md).

`/example` contains an example docker-compose file and config files that show how to start apisix and apisix dashboard using docker compose.
1. Start apisix and apisix dashboard
    ```
    cd example
    docker-compose -p docker-apisix up -d
    ```
 
2. Check if APISIX is running properly by running this command and checking the response.
    ```
    curl "http://127.0.0.1:9080/apisix/admin/services/" -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1'
    ```
     The response indicates that apisix is running successfully:
    ```
    {
      "count":0,
      "action":"get",
      "node":{
        "key":"/apisix/services",
        "nodes":[],
        "dir":true
      }
    }
    ```
 
The example docker compose file defines several services: `apisix-dashboard, apisix, etcd, web1, web2, prometheus, and grafana`:
`apisix-dashboard, apisix, etcd` are the essential services required for starting apisix-dashboard, apisix, etcd.
`web1, web2` are sample backend services used for testing purposes.
`prometheus, grafana` are services used for exposing metrics of the running services.
 It also creates a bridge network `apisix` which connects all services and a `etcd_data` volume used by the `etcd` service. 

All the services are configured by mounting external configuration files onto the containers: `./dashboard_conf/conf.yaml` defines the configs for `apisix-dashboard`; `./apisix_conf/conf.yaml` defines the configs for apisix. Similarly, configs for etcd, prometheus, and grafana are located in the corresponding conf.yaml files. If you want to use a config file from a different path, you need to modify the local config file path in the `volumes` entry under the corresponding service.

## Quick test with all dependencies in one Docker container
A quick way to get APISIX running on alpine is to use the provided all-in-one docker images, which deploys all dependencies in one Docker container. 

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
## Useful commands

Below are some useful commands which build, push, and tar your updated images.
As an example, these are the commands for apisix-centos images:

-   ```make build-on-centos``` : Build apache/apisix:xx-centos image. 

-   ```make push-on-centos```: Build and push apache/apisix:xx-centos image.

-  ```make save-centos-tar```:  Save apache/apisix:xx-centos image to a tar archive located at ```./package``` . 

Similar commands exist for apisix-alpine images and apisix dashboard. See [the makefile](/Makefile) for a full list of commands. 

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
