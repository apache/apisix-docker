## Docker distribution for APISIX

You can install multiple versions of APISIX through docker:

1. install the latest stable version:
```
docker build -t iresty/apisix -f alpine/Dockerfile alpine
```

2. install master branch version, which has latest code:
```
docker build -t apisix:master-alpine --build-arg APISIX_VERSION=master -f alpine/Dockerfile alpine
```

3. install history versions:
```
docker build -t apisix:0.7-alpine --build-arg APISIX_VERSION=0.7 -f alpine/Dockerfile alpine
```


## Run APISIX with etcd
You need etcd docker to work with APISIX. You can refer to
 [the docker-compose example](example/README.md).

Or you can run APISIX with Docker directly(Docker name is test-api-gateway):
```
docker run  --name test-api-gateway  -v ./example/apisix_conf/config.yaml:/usr/local/apisix/conf/config.yaml  -v./example/apisix_log:/usr/local/apisix/logs  -p 8080:9080 -p  8083:9443 -d  iresty/apisix
```

NOTE: macOS not supports `host` network mode, so Linux is recommended.
