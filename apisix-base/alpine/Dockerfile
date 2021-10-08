ARG IMAGE_BASE="alpine"
ARG IMAGE_TAG="3.12"

FROM ${IMAGE_BASE}:${IMAGE_TAG}

COPY build-apisix-base.sh /tmp/build-apisix-base.sh


ARG RESTY_OPENSSL_VERSION="1.1.1g"
ARG RESTY_OPENSSL_PATCH_VERSION="1.1.1f"
ARG RESTY_OPENSSL_URL_BASE="https://www.openssl.org/source"
ARG RESTY_PCRE_VERSION="8.44"
ARG RESTY_J="1"
ARG RESTY_EVAL_PRE_CONFIGURE=""

LABEL resty_image_base="${RESTY_IMAGE_BASE}"
LABEL resty_image_tag="${IMAGE_TAG}"
LABEL resty_openssl_version="${RESTY_OPENSSL_VERSION}"
LABEL resty_openssl_patch_version="${RESTY_OPENSSL_PATCH_VERSION}"
LABEL resty_openssl_url_base="${RESTY_OPENSSL_URL_BASE}"
LABEL resty_pcre_version="${RESTY_PCRE_VERSION}"
LABEL resty_eval_pre_configure="${RESTY_EVAL_PRE_CONFIGURE}"


RUN apk add --no-cache --virtual .build-deps \
        build-base \
        coreutils \
        curl \
        gd-dev \
        geoip-dev \
        libxslt-dev \
        linux-headers \
        make \
        perl-dev \
        readline-dev \
        zlib-dev \
    && apk add --no-cache \
        gd \
        geoip \
        libgcc \
        libxslt \
        zlib \
        bash \
        git \
        sudo \
        curl

RUN cd /tmp \
    && if [ -n "${RESTY_EVAL_PRE_CONFIGURE}" ]; then eval $(echo ${RESTY_EVAL_PRE_CONFIGURE}); fi \
    && cd /tmp \
    && curl -fSL "${RESTY_OPENSSL_URL_BASE}/openssl-${RESTY_OPENSSL_VERSION}.tar.gz" -o openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
    && tar xzf openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
    && cd openssl-${RESTY_OPENSSL_VERSION} \
    && echo 'patching OpenSSL 1.1.1 for OpenResty' \
    && curl -s https://raw.githubusercontent.com/openresty/openresty/master/patches/openssl-${RESTY_OPENSSL_PATCH_VERSION}-sess_set_get_cb_yield.patch | patch -p1 \
    && ./config \
      no-threads shared zlib -g \
      enable-ssl3 enable-ssl3-method \
      --prefix=/usr/local/openresty/openssl111 \
      --libdir=lib \
      -Wl,-rpath,/usr/local/openresty/openssl111/lib \
    && make -j${RESTY_J} \
    && make -j${RESTY_J} install_sw

RUN cd /tmp \
    && curl -fSL https://ftp.pcre.org/pub/pcre/pcre-${RESTY_PCRE_VERSION}.tar.gz -o pcre-${RESTY_PCRE_VERSION}.tar.gz \
    && tar xzf pcre-${RESTY_PCRE_VERSION}.tar.gz \
    && cd /tmp/pcre-${RESTY_PCRE_VERSION} \
    && ./configure \
        --prefix=/usr/local/openresty/pcre \
        --disable-cpp \
        --enable-jit \
        --enable-utf \
        --enable-unicode-properties \
    && make -j${RESTY_J} \
    && make -j${RESTY_J} install

RUN cd /tmp \
    && ./build-apisix-base.sh

CMD /bin/sh
