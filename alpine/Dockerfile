ARG RESTY_IMAGE_BASE="openresty/openresty"
ARG RESTY_IMAGE_TAG="alpine-fat"
# require alpine-fat >= 1.15.8.1-3
FROM ${RESTY_IMAGE_BASE}:${RESTY_IMAGE_TAG}

MAINTAINER vkill <vkill.net@gmail.com>

#
# docker build -t apisix:v0.5-alpine -f alpine/Dockerfile alpine
# docker build -t apisix:dev-alpine --build-arg APISIX_VERSION=master --build-arg APISIX_DOWNLOAD_SHA256=SKIP -f alpine/Dockerfile alpine
# docker build -t apisix:my-alpine --build-arg APISIX_GITHUB_REPO=https://github.com/YOU/apisix --build-arg APISIX_VERSION=BRANCHNAME --build-arg APISIX_DOWNLOAD_SHA256=SKIP -f alpine/Dockerfile alpine
#
ARG APISIX_VERSION=v0.5
ENV APISIX_VERSION=${APISIX_VERSION}
ARG APISIX_GITHUB_REPO=https://github.com/iresty/apisix
ENV APISIX_DOWNLOAD_URL ${APISIX_GITHUB_REPO}/archive/${APISIX_VERSION}.zip
ARG APISIX_DOWNLOAD_SHA256=e6f14dcd58c5ba286ee48f8482a669893560bc2fbc90d6bf52881493ce720fb7
ENV APISIX_DOWNLOAD_SHA256=${APISIX_DOWNLOAD_SHA256}

RUN set -ex \
  \
  # && sed -i 's!dl-cdn.alpinelinux.org!mirrors.aliyun.com!' /etc/apk/repositories \
  \
  && apk add --no-cache --virtual .rundeps \
    curl \
  \
  && apk add --no-cache --virtual .builddeps \
    unzip \
    build-base \
    make \
    sudo \
    git \
    automake \
    autoconf \
    libtool \
    pkgconfig \
    cmake \
  \
  && ln -sf /usr/local/openresty/luajit/bin/luajit /usr/bin/lua \
  && mkdir -p /usr/local/lib/pkgconfig \
  && mkdir -p /usr/local/include \
  && ln -sf /usr/local/openresty/pcre/lib/libpcre.so /usr/local/lib/libpcre.so \
  && ln -sf /usr/local/openresty/pcre/lib/pkgconfig/libpcre.pc /usr/local/lib/pkgconfig/libpcre.pc \
  && ln -sf /usr/local/openresty/pcre/include/pcre.h /usr/local/include/pcre.h \
  \
  && wget -O apisix.zip "${APISIX_DOWNLOAD_URL}" \
  && [[ "${APISIX_DOWNLOAD_SHA256}" = "SKIP" ]] && echo "SKIP" || (echo "${APISIX_DOWNLOAD_SHA256} *apisix.zip" | sha256sum -c -) \
  \
  && mkdir -p /usr/src \
  && unzip apisix.zip -d /usr/src \
  && rm apisix.zip \
  \
  && cd "/usr/src/apisix-`echo ${APISIX_VERSION} | sed 's/^v//'`" \
  \
  && make dev \
  && make install \
  && cp -r deps /usr/local/apisix/ \
  && sed -i '/pcall(require, "cjson")$/,/^end$/s/return$/-- return/' /usr/bin/apisix \
  \
  && cd / \
  && rm -r "/usr/src/apisix-`echo ${APISIX_VERSION} | sed 's/^v//'`" \
  \
  && apk del .builddeps

WORKDIR /usr/local/apisix

CMD ["sh", "-c", "/usr/bin/apisix init && /usr/bin/apisix init_etcd && /usr/local/openresty/bin/openresty -p /usr/local/apisix -g 'daemon off;'"]
