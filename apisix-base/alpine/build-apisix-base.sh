#!/usr/bin/env bash
set -euo pipefail
set -x

if [ $# -gt 0 ] && [ "$1" == "latest" ]; then
    ngx_multi_upstream_module_ver=""
    mod_dubbo_ver=""
    apisix_nginx_module_ver=""
    lua_var_nginx_module_ver=""
    debug_args="--with-debug"
    OR_PREFIX=${OR_PREFIX:="/usr/local/openresty-debug"}
else
    ngx_multi_upstream_module_ver="-b 1.0.0"
    mod_dubbo_ver="-b 1.0.0"
    apisix_nginx_module_ver="-b 1.3.0"
    lua_var_nginx_module_ver="-b v0.5.2"
    debug_args=${debug_args:-}
    OR_PREFIX=${OR_PREFIX:="/usr/local/openresty"}
fi

prev_workdir="$PWD"
repo=$(basename "$prev_workdir")
workdir=$(mktemp -d)
cd "$workdir" || exit 1

or_ver="1.19.3.2"
wget https://openresty.org/download/openresty-${or_ver}.tar.gz
tar -zxvpf openresty-${or_ver}.tar.gz

if [ "$repo" == ngx_multi_upstream_module ]; then
    cp -r "$prev_workdir" .
else
    git clone --depth=1 $ngx_multi_upstream_module_ver \
        https://github.com/api7/ngx_multi_upstream_module.git
fi

if [ "$repo" == mod_dubbo ]; then
    cp -r "$prev_workdir" .
else
    git clone --depth=1 $mod_dubbo_ver \
        https://github.com/api7/mod_dubbo.git
fi

if [ "$repo" == apisix-nginx-module ]; then
    cp -r "$prev_workdir" .
else
    git clone --depth=1 $apisix_nginx_module_ver \
        https://github.com/api7/apisix-nginx-module.git
fi

if [ "$repo" == lua-var-nginx-module ]; then
    cp -r "$prev_workdir" .
else
    git clone --depth=1 $lua_var_nginx_module_ver \
        https://github.com/api7/lua-var-nginx-module
fi

cd ngx_multi_upstream_module || exit 1
./patch.sh ../openresty-${or_ver}
cd ..

cd apisix-nginx-module/patch || exit 1
./patch.sh ../../openresty-${or_ver}
cd ../..

version=${version:-0.0.0}
cc_opt=${cc_opt:-}
ld_opt=${ld_opt:-}
luajit_xcflags=${luajit_xcflags:="-DLUAJIT_NUMMODE=2 -DLUAJIT_ENABLE_LUA52COMPAT"}
no_pool_patch=${no_pool_patch:-}

cd openresty-${or_ver} || exit 1
./configure --prefix="$OR_PREFIX" \
    --with-cc-opt="-DAPISIX_OPENRESTY_VER=$version $cc_opt" \
    --with-ld-opt="$ld_opt" \
    --add-module=../mod_dubbo \
    --add-module=../ngx_multi_upstream_module \
    --add-module=../apisix-nginx-module \
    --add-module=../lua-var-nginx-module \
    $debug_args \
    --with-poll_module \
    --with-pcre-jit \
    --without-http_rds_json_module \
    --without-http_rds_csv_module \
    --without-lua_rds_parser \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-http_v2_module \
    --without-mail_pop3_module \
    --without-mail_imap_module \
    --without-mail_smtp_module \
    --with-http_stub_status_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_secure_link_module \
    --with-http_random_index_module \
    --with-http_gzip_static_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-threads \
    --with-compat \
    --with-luajit-xcflags="$luajit_xcflags" \
    $no_pool_patch \
    -j`nproc`

make -j`nproc`
sudo make install
cd ..

cd apisix-nginx-module || exit 1
sudo OPENRESTY_PREFIX="$OR_PREFIX" make install
