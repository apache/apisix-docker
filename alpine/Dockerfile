ARG RESTY_IMAGE_BASE="openresty/openresty"
ARG RESTY_IMAGE_TAG="alpine-fat"

FROM ${RESTY_IMAGE_BASE}:${RESTY_IMAGE_TAG}

ARG APISIX_VERSION=0.8

LABEL apisix_version="${APISIX_VERSION}"

RUN apk add --no-cache --virtual .builddeps \
        automake \
        autoconf \
        libtool \
        pkgconfig \
        cmake \
        git \
    && if [ ${APISIX_VERSION} = "master" ] ; then \
        APISIX_VERSION="dev-1.0"; \
    fi \
    && luarocks install https://github.com/iresty/apisix/raw/master/rockspec/apisix-${APISIX_VERSION}-0.rockspec --tree=/usr/local/apisix/deps \
    && cp /usr/local/apisix/deps/lib/luarocks/rocks-5.1/apisix/${APISIX_VERSION}-0/bin/apisix /usr/bin/ \
    && bin='#! /usr/local/openresty/luajit/bin/luajit' \
    && sed -i "1s@.*@$bin@" /usr/bin/apisix \
    && apk del .builddeps

WORKDIR /usr/local/apisix

EXPOSE 9080 9443

CMD ["sh", "-c", "/usr/bin/apisix init && /usr/bin/apisix init_etcd && /usr/local/openresty/bin/openresty -p /usr/local/apisix -g 'daemon off;'"]