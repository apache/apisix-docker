## Build an image from source

**Docker images are not official ASF releases but provided for convenience. Recommended usage is always to build the source.**

1. install release version (Apache releases are beginning from version 0.9):
```
# Assign Apache release version number to variable `APISIX_VERSION`, for example: 2.2 . The latest version can be find at `https://github.com/apache/apisix/releases`

APISIX_VERSION=2.2
docker build -t apisix:${APISIX_VERSION}-alpine --build-arg APISIX_VERSION=${APISIX_VERSION} -f alpine/Dockerfile alpine
```

2. install master branch version, which has latest code(ONLY for the developer's convenience):
```
docker build -t apisix:master-alpine -f alpine/Dockerfile alpine
```
