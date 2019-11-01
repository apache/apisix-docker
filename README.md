## Prerequisites

To run this application you need [Docker Engine](https://www.docker.com/products/docker-engine) >= `1.10.0`. [Docker Compose](https://www.docker.com/products/docker-compose) is recommended with a version `1.6.0` or later.

## Get this image

#### Step 1: pull this etcd image

```
$ docker pull bitnami/etcd:3.3.13-r80
```

#### Step 2: pull this apisix image

```
$ docker pull iresty/apisix:latest
```
If you wish, you can also build the image yourself.

> 1.install master branch version, which has latest code:
```
$ docker build -t apisix:master-alpine -f alpine/Dockerfile alpine
```

> 2.install release versions:
```
$ docker build -t apisix:0.8-alpine --build-arg APISIX_VERSION=0.8 -f alpine/Dockerfile alpine
```

## Using the Command Line

#### Step 1: Launch the etcd server instance

```
$ docker run -it --name etcd-server \
-v ./example/etcd_conf/etcd.conf.yml:/opt/bitnami/etcd/conf/etcd.conf.yml \
-p 2379:2379 \
-p 2380:2380  \
--env ALLOW_NONE_AUTHENTICATION=yes bitnami/etcd:3.3.13-r80
```

> Note:
> 1. windows OS use absolute paths to hang in the configuration file.
> 2. e.g：windows dir path `E:\GitHub\docker-apisix `，configuration  file hang path is `-v /e/github/docker-apisix/example/etcd_conf/etcd.conf.yml:/opt/bitnami/etcd/conf/etcd.conf.yml`

#### Step 2: Modify `etcd` config `host` 

modify `example/apisix_conf/config.yaml` the `etcd` config `host` address of etcd in the file to the host (intranet) ip address, for example: `192.168.1.3`. As 
```
etcd:
  host: "http://192.168.1.3:2379"   # etcd address
```
#### Step 3: Launch the APISIX server instance

```
$ docker run --name test-api-gateway \
-v ./example/apisix_conf/config.yaml:/usr/local/apisix/conf/config.yaml \ 
-v ./example/apisix_log:/usr/local/apisix/logs  \
-p 8080:9080 \ 
-p 8083:9443 \
-d iresty/apisix
```
> Note:
> 1. mac OS not supports `host` network mode, so Linux is recommended.
> 2. windows OS use absolute paths to hang in the configuration file and log dir.
> 3. if the official image pull timeout : `request canceled (Client.Timeout exceeded while awaiting headers)`,  it is recommended to use AliYun primary container registry mirror 

#### Step 4: This Open Demo Dashboard

[http://127.0.0.1:8080/apisix/dashboard](http://127.0.0.1:8080/apisix/dashboard)

## Using Docker Compose

Launch the containers using:

```
docker-compose up -d
```