FROM node:10-alpine3.11 AS build-stage

ARG APISIX_VERSION=1.1

RUN set -x \
    && /bin/sed -i 's,http://dl-cdn.alpinelinux.org,https://mirrors.aliyun.com,g' /etc/apk/repositories \
    && apk add --no-cache --virtual .build-deps git \
    && git clone -b v${APISIX_VERSION} https://github.com/apache/incubator-apisix.git /tmp/apisix \
    && cd /tmp/apisix \
    && git submodule init \
    && git submodule update \
    && cd dashboard \
    && yarn && yarn build:prod

FROM openresty/openresty:alpine-fat AS production-stage

ARG APISIX_VERSION=1.1
LABEL apisix_version="${APISIX_VERSION}"

RUN set -x \
    && /bin/sed -i 's,http://dl-cdn.alpinelinux.org,https://mirrors.aliyun.com,g' /etc/apk/repositories \
    && apk add --no-cache --virtual .builddeps \
    automake \
    autoconf \
    libtool \
    pkgconfig \
    cmake \
    git \
    && luarocks install https://github.com/apache/incubator-apisix/raw/master/rockspec/apisix-${APISIX_VERSION}-0.rockspec --tree=/usr/local/apisix/deps \
    && cp -v /usr/local/apisix/deps/lib/luarocks/rocks-5.1/apisix/${APISIX_VERSION}-0/bin/apisix /usr/bin/ \
    && bin='#! /usr/local/openresty/luajit/bin/luajit\npackage.path = "/usr/local/apisix/?.lua;" .. package.path' \
    && sed -i "1s@.*@$bin@" /usr/bin/apisix \
    && mv /usr/local/apisix/deps/share/lua/5.1/apisix /usr/local/apisix \
    && apk del .builddeps build-base make unzip

COPY --from=build-stage /tmp/apisix/dashboard/dist/ /usr/local/apisix/dashboard/

WORKDIR /usr/local/apisix

EXPOSE 9080 9443

CMD ["sh", "-c", "/usr/bin/apisix init && /usr/bin/apisix init_etcd && /usr/local/openresty/bin/openresty -p /usr/local/apisix -g 'daemon off;'"]
