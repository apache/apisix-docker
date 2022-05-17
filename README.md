## What is APISIX?

Apache APISIX is a dynamic, real-time, high-performance API gateway. APISIX provides rich traffic management features such as load balancing, dynamic upstream, canary release, circuit breaking, authentication, observability, and more.

See https://apisix.apache.org/ for more info.

## Image variants

The APISIX image comes in many flavors, each designed for a specific use case.

`apisix:<version>`

This is the defacto image. If you are unsure about what your needs are, you probably want to use this one. It is designed to be used both as a throw away container (mount your source code and start the container to start your app), as well as the base to build other images off of.

`apisix:<version>-alpine`

This image is based on the popular Alpine Linux project, available in the alpine official image. Alpine Linux is much smaller than most distribution base images (~5MB), and thus leads to much slimmer images in general.

This variant is useful when final image size being as small as possible is your primary concern. The main caveat to note is that it does use musl libc instead of glibc and friends, so software will often run into issues depending on the depth of their libc requirements/assumptions. See this Hacker News comment thread for more discussion of the issues that might arise and some pro/con comparisons of using Alpine-based images.

To minimize image size, it's uncommon for additional related tools (such as git or bash) to be included in Alpine-based images. Using this image as a base, add the things you need in your own Dockerfile (see the alpine image description for examples of how to install packages if you are unfamiliar).

`apisix:<version>-centos`

## How to run APISIX?

APISIX can be run using docker compose or using the `all-in-one` image. It is recommended to use docker compose to run APISIX, as `all-in-one` deploys all dependencies in a single container and should be used for quick testing.
If you want to manually deploy services, please refer to [this guide](https://github.com/apache/apisix-docker/blob/master/docs/en/latest/manual.md).

### Run APISIX with docker-compose

[The apisix-docker repo](https://github.com/apache/apisix-docker/blob/master/example) contains an example docker-compose file and config files that show how to start APISIX and APISIX dashboard using docker compose.

To try out this example:

1. Clone the [repo]((https://github.com/apache/apisix-docker/blob/master) and cd into the root folder.
  
2. Start apisix and apisix dashboard
    ```
    cd example

    docker-compose -p docker-apisix up -d
    ```

3. Check if APISIX is running properly by running this command and checking the response.
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

The [example docker compose file](https://github.com/apache/apisix-docker/blob/master/example/docker-compose.yml) defines several services: `apisix-dashboard, apisix, etcd, web1, web2, prometheus, and grafana`:
`apisix-dashboard, apisix, etcd` are the essential services required for starting apisix-dashboard, apisix, etcd.
`web1, web2` are sample backend services used for testing purposes.
`prometheus, grafana` are services used for exposing metrics of the running services.

All the services are configured by mounting external configuration files onto the containers: [./apisix_conf/conf.yaml](https://github.com/apache/apisix-docker/blob/master/example/apisix_conf/conf.yaml) defines the configs for apisix. Similarly, configs for etcd, prometheus, and grafana are located in the corresponding conf.yaml files. 

If you want to use a config file from a different path, you need to modify the local config file path in the `volumes` entry under the corresponding service.

### Run APISIX with all-in-one command 

A quick way to get APISIX running on alpine is to use the `all-in-one` docker image, which deploys all dependencies in one Docker container. You can find the dockerfile [here](https://github.com/apache/apisix-docker/blob/master/all-in-one/apisix/Dockerfile).

- All in one Docker container for Apache APISIX

```sh
make build-all-in-one

# launch APISIX container
docker run -d \
-p 9080:9080 -p 9091:9091 -p 2379:2379 \
-v `pwd`/all-in-one/apisix/config.yaml:/usr/local/apisix/conf/config.yaml \
apache/apisix:whole
```

The configuration file for the service is located at [/all-in-one/apisix/config.yaml](https://github.com/apache/apisix-docker/blob/master/all-in-one/apisix/config.yaml). It is mounted onto the container at runtime.

- All in one Docker container for Apache apisix-dashboard

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

## How To Build this Image?

[The apisix-docker repo](https://github.com/apache/apisix-docker) contains a list of makefile commands which makes it easy to build images. 

There are two build arguments that can be set:
`APISIX_VERSION`: To build the APISIX image, specify the version of APISIX by setting `APISIX_VERSION`. The latest release version can be found at https://github.com/apache/apisix/releases. 
`ENABLE_PROXY`: Set `ENABLE_PROXY=true` to enable the proxy to accelerate the build process.

To use these commands, clone [the repo](https://github.com/apache/apisix-docker) and cd into its root folder.

```sh
# The latest release version can be find at `https://github.com/apache/apisix/releases`, for example: 2.9
export APISIX_VERSION=2.9

# build alpine based image
make build-on-alpine

# build centos based image
make build-on-centos
```

Alternatively, you can build APISIX from your local code.
```sh
# To copy the local apisix into image, we need to include it in build context
cp -r <APISIX-PATH> ./apisix

export APISIX_PATH=./apisix
make build-on-alpine-local

# Might need root privilege if encounter "error checking context: 'can't start'"
```

**Note:** For Chinese, the following command is always recommended. The additional build argument `ENABLE_PROXY=true` will enable proxy to definitely accelerate the progress.

To build the APISIX dashboard image, specify the version of APISIX dashboard by setting `APISIX_DASHBOARD_VERSION`. The latest release version can be found at https://github.com/apache/apisix-dashboard/releases.

```sh
# The latest release version can be found at `https://github.com/apache/apisix-dashboard/releases`, for example: 2.10
export APISIX_DASHBOARD_VERSION=2.10

# build alpine based image
make build-dashboard-alpine

# build centos based image
make build-dashboard-centos
```

Note that we are not able to run APISIX yet because etcd, which APISIX depends on to persist data, has not been configured and started. The following section shows two ways to run APISIX.

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
