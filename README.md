## What is APISIX

Apache APISIX is a dynamic, real-time, high-performance API gateway. APISIX provides rich traffic management features such as load balancing, dynamic upstream, canary release, circuit breaking, authentication, observability, and more.

See [the APISIX website](https://apisix.apache.org/) for more info.

## Image variants

The APISIX image comes in many flavors, each designed for a specific use case.

`apisix:<version>`

This is the default image. If you are unsure about what your needs are, this is your go-to option.you can use it as a throw away container (mount your source code and start the container to start your applications), as well as the base to build other images of.

`apisix:<version>-alpine`

This image is based on the popular Alpine Linux project, available in the alpine official image. Alpine Linux is much smaller than most distribution base images (~5MB), and thus leads to much slimmer images in general.

This variant is useful when final image size being as small as possible is your primary concern. The main caveat to note is that it does use musl libc instead of glibc and friends, so software will often run into issues depending on the depth of their libc requirements/assumptions. See this Hacker News comment thread for more discussion of the issues that might arise and some pro/con comparisons of using Alpine-based images.

To minimize image size, it's uncommon for additional related tools (such as git or bash) to be included in Alpine-based images. Using this image as a base, add the things you need in your own Dockerfile (see the alpine image description for examples of how to install packages if you are unfamiliar).

`apisix:<version>-centos`

This image is based on the CentOS Linux project, available in the centos official image. CentOS is derived from the sources of Red Hat Enterprise Linux (RHEL). It is considered to be a more stable distribution compared to Ubuntu, mainly because package updates are less frequent.

The variant is useful when your primary concern is stability and want to minimize the number of image updates. The applications running on CentOS don't need to be updated as often owing to the lesser frequency of its updates, and the cost is also very less than compared with other Linux essentials.

## How to run APISIX

APISIX can be run using docker compose or using the `all-in-one` image. It is recommended to use docker compose to run APISIX, as `all-in-one` deploys all dependencies in a single container and should be used for quick testing.
If you want to manually deploy services, please refer to [this guide](https://github.com/apache/apisix-docker/blob/master/docs/en/latest/manual.md).

### Run APISIX with docker-compose

[The apisix-docker repo](https://github.com/apache/apisix-docker/blob/master/example) contains an example docker-compose file and config files that show how to start APISIX using docker compose. For the sake of completeness, this docker-compose file also starts [APISIX dashboard](https://hub.docker.com/r/apache/apisix-dashboard), which is a frontend interface that makes it easy for users to interact with APISIX, along with Prometheus and Grafana.

To try out this example:

1. Clone the [repo](https://github.com/apache/apisix-docker) and cd into the root folder.
  
2. Start APISIX.
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
- `apisix-dashboard, apisix, etcd` are the essential services required for starting apisix-dashboard, apisix, etcd.
- `web1, web2` are sample backend services used for testing purposes. They use nginx-alpine image.  
- `prometheus, grafana` are services used for exposing metrics of the running services.

All the services are configured by mounting external configuration files onto the containers: [/apisix_conf/conf.yaml](https://github.com/apache/apisix-docker/blob/master/example/apisix_conf/config.yaml) defines the configs for apisix. Similarly, configs for etcd, prometheus, and grafana are located in [/etcd_conf/etcd.conf.yml](https://github.com/apache/apisix-docker/blob/master/example/etcd_conf/etcd.conf.yml), [/prometheus_conf/prometheus.yml](https://github.com/apache/apisix-docker/blob/master/example/prometheus_conf/prometheus.yml), and [/grafana_conf/config](https://github.com/apache/apisix-docker/tree/master/example/grafana_conf/config) respectively.

If you want to use a config file located at a different path, you need to modify the local config file path in the `volumes` entry under the corresponding service.

### Run APISIX with all-in-one command

A quick way to get APISIX running on alpine is to use the `all-in-one` docker image, which deploys all dependencies in one Docker container. You can find the dockerfile [here](https://github.com/apache/apisix-docker/blob/master/all-in-one/apisix/Dockerfile). The image utilizes [multi-stage build](https://docs.docker.com/develop/develop-images/multistage-build/), building APISIX layer and etcd layer first, then copying the nesessary artifacts to the alpine layer.

To try out this example:

1. Clone the [apisix-docker repo](https://github.com/apache/apisix-docker/blob/master) and cd into the root folder.

2. `make build-all-in-one` to build the `all-in-one` image.

3. Launch the APISIX container:

    ```sh
    docker run -d \
    -p 9080:9080 -p 9091:9091 -p 2379:2379 \
    -v `pwd`/all-in-one/apisix/config.yaml:/usr/local/apisix/conf/config.yaml \
    apache/apisix:whole
    ```

4. Check if APISIX is running properly by running this command and checking the response.
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

The configuration file for the service is located at [/all-in-one/apisix/config.yaml](https://github.com/apache/apisix-docker/blob/master/all-in-one/apisix/config.yaml). It is mounted onto the container at runtime.

## How To Build this Image

The apisix-docker repo contains a list of makefile commands which makes it easy to build images. To use these commands, clone [the repo](https://github.com/apache/apisix-docker) and cd into its root folder.

There are two build arguments that can be set:
`APISIX_VERSION`: To build the APISIX image, specify the version of APISIX by setting `APISIX_VERSION`. The latest. release version can be found here [apisix/releases](https://github.com/apache/apisix/releases).
`ENABLE_PROXY`: Set `ENABLE_PROXY=true` to enable the proxy to accelerate the build process.

```sh
# make sure that you are in the root folder of https://github.com/apache/apisix-docker
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
