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

FROM debian:bullseye-slim

ARG APISIX_VERSION=3.10.0

RUN set -ex; \
    arch=$(dpkg --print-architecture); \
    apt update; \
    apt-get -y install --no-install-recommends wget gnupg ca-certificates curl;\
    codename=`grep -Po 'VERSION="[0-9]+ \(\K[^)]+' /etc/os-release`; \
    case "${arch}" in \
      amd64) \
        wget -O - https://repos.apiseven.com/pubkey.gpg | apt-key add - \
        && echo "deb https://repos.apiseven.com/packages/debian $codename main" | tee /etc/apt/sources.list.d/apisix.list \
        ;; \
      arm64) \
        wget -O - https://repos.apiseven.com/pubkey.gpg | apt-key add - \
        && echo "deb https://repos.apiseven.com/packages/arm64/debian $codename main" | tee /etc/apt/sources.list.d/apisix.list \
        ;; \
    esac; \
    apt update \
    && apt install -y apisix=${APISIX_VERSION}-0 \
    && apt-get purge -y --auto-remove \
    && rm /usr/local/openresty/bin/etcdctl \
    && openresty -V \
    && apisix version

COPY ./install-brotli.sh /install-brotli.sh
RUN chmod +x /install-brotli.sh \  
    && cd / && ./install-brotli.sh && rm -rf /install-brotli.sh

RUN apt-get -y purge --auto-remove curl wget gnupg --allow-remove-essential

WORKDIR /usr/local/apisix

ENV PATH=$PATH:/usr/local/openresty/luajit/bin:/usr/local/openresty/nginx/sbin:/usr/local/openresty/bin

RUN groupadd --system --gid 636 apisix \
    && useradd --system --gid apisix --no-create-home --shell /usr/sbin/nologin --uid 636 apisix \
    && chown -R apisix:apisix /usr/local/apisix

USER apisix

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /usr/local/apisix/logs/access.log \
    && ln -sf /dev/stderr /usr/local/apisix/logs/error.log

EXPOSE 9080 9443

COPY ./docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["docker-start"]


STOPSIGNAL SIGQUIT
