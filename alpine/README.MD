### When building with `alpine` basic image, please specify `APISIX_VERSION` through `build-arg`

```
docker build --build-arg APISIX_VERSION=$APISIX_VERSION -t $IMAGE_NAME .
```