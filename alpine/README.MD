### When building with `alpine` basic image, please specify `APISIX_VERSION` through `build-arg`

```shell
$ docker build --build-arg APISIX_VERSION=$APISIX_VERSION -t $IMAGE_NAME .
```

Note: The minimum version of docker that supports building image is `docker 17.05.0-ce`.
