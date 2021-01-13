FROM centos:7

ARG APISIX_VERSION=2.2
LABEL apisix_version="${APISIX_VERSION}"

RUN yum -y install yum-utils\
	&& yum-config-manager --add-repo https://openresty.org/package/centos/openresty.repo \
	&& yum install -y openresty \
	&& yum install -y https://github.com/apache/apisix/releases/download/$APISIX_VERSION/apisix-$APISIX_VERSION-0.x86_64.rpm \
	&& yum clean all \
	&& sed -i 's/PASS_MAX_DAYS\t99999/PASS_MAX_DAYS\t60/g' /etc/login.defs

WORKDIR /usr/local/apisix

EXPOSE 9080 9443

CMD ["sh", "-c", "/usr/bin/apisix init && /usr/bin/apisix init_etcd && /usr/local/openresty/bin/openresty -p /usr/local/apisix -g 'daemon off;'"]

