ARG ENABLE_PROXY=false

FROM openresty/openresty:alpine-fat AS production-stage

ARG APISIX_VERSION=master
LABEL apisix_version="${APISIX_VERSION}"

ARG ENABLE_PROXY
RUN set -x \
    && (test "${ENABLE_PROXY}" != "true" || /bin/sed -i 's,http://dl-cdn.alpinelinux.org,https://mirrors.aliyun.com,g' /etc/apk/repositories) \
    && apk add --no-cache --virtual .builddeps \
    automake \
    autoconf \
    libtool \
    pkgconfig \
    cmake \
    git \
    && luarocks install https://github.com/apache/apisix/raw/master/rockspec/apisix-${APISIX_VERSION}-0.rockspec --tree=/usr/local/apisix/deps \
    && cp -v /usr/local/apisix/deps/lib/luarocks/rocks-5.1/apisix/${APISIX_VERSION}-0/bin/apisix /usr/bin/ \
    && bin='#! /usr/local/openresty/luajit/bin/luajit\npackage.path = "/usr/local/apisix/?.lua;" .. package.path' \
    && sed -i "1s@.*@$bin@" /usr/bin/apisix \
    && mv /usr/local/apisix/deps/share/lua/5.1/apisix /usr/local/apisix \
    && apk del .builddeps build-base make unzip


FROM alpine:3.11 AS etcd-stage

ARG ETCD_VERSION=v3.4.14
LABEL etcd_version="${ETCD_VERSION}"

WORKDIR /tmp
RUN wget https://github.com/etcd-io/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz \
    && tar -zxvf etcd-${ETCD_VERSION}-linux-amd64.tar.gz \
    && ln -s etcd-${ETCD_VERSION}-linux-amd64 etcd


FROM alpine:latest as pre-build

ARG APISIX_DASHBOARD_VERSION=master

RUN set -x \
    && wget https://github.com/apache/apisix-dashboard/archive/${APISIX_DASHBOARD_VERSION}.tar.gz -O /tmp/apisix-dashboard.tar.gz \
    && mkdir /usr/local/apisix-dashboard \
    && tar -xvf /tmp/apisix-dashboard.tar.gz -C /usr/local/apisix-dashboard --strip 1


FROM golang:1.14 as api-builder

ARG ENABLE_PROXY
ARG APISIX_DASHBOARD_VERSION=master

WORKDIR /usr/local/apisix-dashboard

COPY --from=pre-build /usr/local/apisix-dashboard .

WORKDIR /usr/local/apisix-dashboard/api

RUN mkdir -p ../output/conf \
    && cp ./conf/*.json ../output/conf \
    && wget https://github.com/api7/dag-to-lua/archive/v1.1.tar.gz -O /tmp/v1.1.tar.gz \
    && mkdir /tmp/dag-to-lua \
    && tar -xvf /tmp/v1.1.tar.gz -C /tmp/dag-to-lua --strip 1 \
    && mkdir -p ../output/dag-to-lua \
    && mv /tmp/dag-to-lua/lib/* ../output/dag-to-lua/ \
    && if [ "$ENABLE_PROXY" = "true" ] ; then go env -w GOPROXY=https://goproxy.io,direct ; fi \
    && go env -w GO111MODULE=on \
    && if [ "$APISIX_DASHBOARD_VERSION" = "master" ] || [ "$APISIX_DASHBOARD_VERSION" \> "v2.2" ]; then CGO_ENABLED=0 go build -o ../output/manager-api ./cmd/manager; else CGO_ENABLED=0 go build -o ../output/manager-api . ; fi;


FROM node:14-alpine as fe-builder

ARG ENABLE_PROXY=false

WORKDIR /usr/local/apisix-dashboard

COPY --from=pre-build /usr/local/apisix-dashboard .

WORKDIR /usr/local/apisix-dashboard/web

RUN if [ "$ENABLE_PROXY" = "true" ] ; then yarn config set registry https://registry.npm.taobao.org/ ; fi \
    && yarn install \
    && yarn build


FROM alpine:3.11 AS last-stage

ARG ENABLE_PROXY
# add runtime for Apache APISIX
RUN set -x \
    && (test "${ENABLE_PROXY}" != "true" || /bin/sed -i 's,http://dl-cdn.alpinelinux.org,https://mirrors.aliyun.com,g' /etc/apk/repositories) \
    && apk add --no-cache bash libstdc++ curl

WORKDIR /usr/local/apisix

COPY --from=production-stage /usr/local/openresty/ /usr/local/openresty/
COPY --from=production-stage /usr/local/apisix/ /usr/local/apisix/
COPY --from=production-stage /usr/bin/apisix /usr/bin/apisix

COPY --from=etcd-stage /tmp/etcd/etcd /usr/bin/etcd
COPY --from=etcd-stage /tmp/etcd/etcdctl /usr/bin/etcdctl

ENV PATH=$PATH:/usr/local/openresty/luajit/bin:/usr/local/openresty/nginx/sbin:/usr/local/openresty/bin

# dashboard

RUN if [ "$ENABLE_PROXY" = "true" ] ; then sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories ; fi \
    && apk add lua5.1

WORKDIR /usr/local/apisix-dashboard

COPY --from=api-builder /usr/local/apisix-dashboard/output/ ./
COPY --from=fe-builder /usr/local/apisix-dashboard/output/ ./

RUN mkdir logs

EXPOSE 9080 9443 2379 2380 9000

CMD ["sh", "-c", "(nohup etcd >/tmp/etcd.log 2>&1 &) && sleep 10 && (/usr/local/apisix-dashboard/manager-api &) && /usr/bin/apisix init && /usr/bin/apisix init_etcd && /usr/local/openresty/bin/openresty -p /usr/local/apisix -g 'daemon off;'"]

STOPSIGNAL SIGQUIT
