FROM centos:7

ARG APISIX_VERSION=2.11.0
LABEL apisix_version="${APISIX_VERSION}"

RUN yum install -y https://repos.apiseven.com/packages/centos/apache-apisix-repo-1.0-1.noarch.rpm \
	&& yum install -y https://repos.apiseven.com/packages/centos/7/x86_64/apisix-$APISIX_VERSION-0.el7.x86_64.rpm \
	&& yum clean all \
	&& sed -i 's/PASS_MAX_DAYS\t99999/PASS_MAX_DAYS\t60/g' /etc/login.defs

WORKDIR /usr/local/apisix
RUN chown -R 1001:1001 /usr/local/apisix

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /usr/local/apisix/logs/access.log \
    && ln -sf /dev/stderr /usr/local/apisix/logs/error.log
USER 1001
EXPOSE 9080 9443

CMD ["sh", "-c", "/usr/bin/apisix init && /usr/bin/apisix init_etcd && /usr/local/openresty/bin/openresty -p /usr/local/apisix -g 'daemon off;'"]

