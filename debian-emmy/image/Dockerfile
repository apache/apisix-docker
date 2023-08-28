#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

FROM api7/apisix-base:dev AS build

ARG ENABLE_PROXY=true

ENV DEBIAN_FRONTEND noninteractive

RUN set -x \
    && (test "${ENABLE_PROXY}" != "true" || /bin/sed -i 's,http://deb.debian.org,http://ftp.cn.debian.org,g' /etc/apt/sources.list) \
    # apt-get install os cmd deps
    && apt-get -y update --fix-missing \
    && apt-get install -y curl \
        gawk \
        git \
        libldap2-dev \
        liblua5.1-0-dev \
        lua5.1 \
        make \
        sudo \
        unzip \
        wget \
        # [Debian Emmy]
        cmake \
        g++ \
    # source code and deps
    && curl https://raw.githubusercontent.com/apache/apisix/master/utils/linux-install-luarocks.sh -sL | bash - \
    && luarocks install https://github.com/apache/apisix/raw/master/rockspec/apisix-master-0.rockspec --tree=/usr/local/apisix/deps PCRE_DIR=/usr/local/openresty/pcre \
    && cp -v /usr/local/apisix/deps/lib/luarocks/rocks-5.1/apisix/master-0/bin/apisix /usr/bin/ \
    && mv /usr/local/apisix/deps/share/lua/5.1/apisix /usr/local/apisix \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stdout /usr/local/apisix/logs/access.log \
    && ln -sf /dev/stderr /usr/local/apisix/logs/error.log

# [Debian Emmy]: build emmy_core.so
WORKDIR /usr/local
RUN set -x \
    && mkdir emmy \
    && wget -O emmy.tar.gz https://github.com/EmmyLua/EmmyLuaDebugger/archive/refs/tags/1.6.3.tar.gz \
    && tar -zxvf emmy.tar.gz \
    && rm emmy.tar.gz
WORKDIR /usr/local/EmmyLuaDebugger-1.6.3
RUN set -x \
    && cmake -DCMAKE_CXX_COMPILER=g++ . \
    && cmake --build . \
    && cp ./emmy_core/emmy_core.so /usr/local/emmy/


FROM api7/apisix-base:dev AS production-stage

COPY --from=build /usr/local/apisix /usr/local/apisix
COPY --from=build /usr/bin/apisix /usr/bin/apisix
COPY --from=build /usr/local/emmy /usr/local/emmy

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /usr/local/apisix

ENV PATH=$PATH:/usr/local/openresty-debug/luajit/bin:/usr/local/openresty-debug/nginx/sbin:/usr/local/openresty-debug/bin

EXPOSE 9080 9443

COPY ./docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["docker-start"]


STOPSIGNAL SIGQUIT
