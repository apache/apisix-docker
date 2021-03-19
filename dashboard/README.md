### build command

```shell
$ docker build --build-arg APISIX_DASHBOARD_VERSION=$APISIX_DASHBOARD_VERSION -t $IMAGE_NAME .
```

Note: The minimum version of docker that supports building image is `docker 17.05.0-ce`.
