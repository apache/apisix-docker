#!/bin/sh

export etcd_url='http://etcd:2379'

wget https://raw.githubusercontent.com/apache/apisix/master/conf/config-default.yaml -O config.yaml

if [[ "$unamestr" == 'Darwin' ]]; then
	sed -i '' -e ':a' -e 'N' -e '$!ba' -e "s/allow_admin[a-z: #\/._]*\n\( *- [0-9a-zA-Z: #\/._',]*\n*\)*//g" config.yaml
	sed -i '' -e "s%http://[0-9.]*:2379%`echo $etcd_url`%g" config.yaml
else
	sed -i -e ':a' -e 'N' -e '$!ba' -e "s/allow_admin[a-z: #\/._]*\n\( *- [0-9a-zA-Z: #\/._',]*\n*\)*//g" config.yaml
	sed -i -e "s%http://[0-9.]*:2379%`echo $etcd_url`%g" config.yaml
fi

mv config.yaml ./apisix_conf/config.yaml