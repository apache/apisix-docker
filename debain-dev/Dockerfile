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

FROM turien/apisix-base:dev AS production-stage

RUN mv /etc/apt/sources.list /etc/apt/sources_bak.list \
    && echo 'deb http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiversee\n\
deb-src http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse\n\
\n\
deb http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse\n\
deb-src http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse\n\
\n\
deb http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse\n\
deb-src http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse\n\
\n\
deb http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse\n\
deb-src http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse\n\
\n\
deb http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse\n\
deb-src http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse\n\
\n\
deb https://mirrors.aliyun.com/ubuntu-ports/ xenial main restricted universe multiverse\n\
deb-src https://mirrors.aliyun.com/ubuntu-ports/ xenial main main restricted universe multiverse\n\
\n\
deb https://mirrors.aliyun.com/ubuntu-ports/ xenial-updates main restricted universe multiverse\n\
deb-src https://mirrors.aliyun.com/ubuntu-ports/ xenial-updates main restricted universe multiverse\n\
\n\
deb https://mirrors.aliyun.com/ubuntu-ports/ xenial-backports main restricted universe multiverse\n\
deb-src https://mirrors.aliyun.com/ubuntu-ports/ xenial-backports main restricted universe multiverse\n\
\n\
deb https://mirrors.aliyun.com/ubuntu-ports/ xenial-security main restricted universe multiverse\n\
deb-src https://mirrors.aliyun.com/ubuntu-ports/ xenial-security main restricted universe multiverse\n'\
> /etc/apt/sources.list

RUN set -x \
    && apt-get -y update --fix-missing \
    && apt autoremove -y libldap-2.4-2 git git-man \
    && apt-get -y install git \
        curl \
        unzip \
        lua5.1 \
        liblua5.1-0-dev \
        libldap2-dev \
        gawk \
    && mv /usr/bin/awk /usr/bin/awk.bak \
    && mv /usr/bin/gawk /usr/bin/awk \
    && git config --global url.https://github.com/.insteadOf git://github.com/ \
    && curl https://raw.githubusercontent.com/apache/apisix/master/utils/linux-install-luarocks.sh -sL | bash - \
    && luarocks install https://github.com/apache/apisix/raw/master/rockspec/apisix-master-0.rockspec --tree=/usr/local/apisix/deps PCRE_DIR=/usr/local/openresty/pcre \
    && cp -v /usr/local/apisix/deps/lib/luarocks/rocks-5.1/apisix/master-0/bin/apisix /usr/bin/ \
    && mv /usr/local/apisix/deps/share/lua/5.1/apisix /usr/local/apisix \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stdout /usr/local/apisix/logs/access.log \
    && ln -sf /dev/stderr /usr/local/apisix/logs/error.log

WORKDIR /usr/local/apisix

ENV PATH=$PATH:/usr/local/openresty-debug/luajit/bin:/usr/local/openresty-debug/nginx/sbin:/usr/local/openresty-debug/bin

EXPOSE 9080 9443

CMD ["sh", "-c", "/usr/bin/apisix init && /usr/bin/apisix init_etcd && /usr/local/openresty/bin/openresty -p /usr/local/apisix -g 'daemon off;'"]

STOPSIGNAL SIGQUIT
