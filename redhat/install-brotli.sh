install_brotli () {
    yum install -y cmake3 wget unzip gcc
    export PATH=$PATH:/usr/local/bin
    local BORTLI_VERSION="1.1.0"
    wget -q https://github.com/google/brotli/archive/refs/tags/v${BORTLI_VERSION}.zip || exit -1
    unzip v${BORTLI_VERSION}.zip && cd ./brotli-${BORTLI_VERSION} && mkdir build && cd build || exit -1
    local CMAKE=$(command -v cmake3 > /dev/null 2>&1 && echo cmake3 || echo cmake) || exit -1
    ${CMAKE} -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local/brotli .. || exit -1
    ${CMAKE} --build . --config Release --target install || exit -1
    if [ -d "/usr/local/brotli/lib64" ]; then
        echo /usr/local/brotli/lib64 | tee /etc/ld.so.conf.d/brotli.conf
    else
        echo /usr/local/brotli/lib | tee /etc/ld.so.conf.d/brotli.conf
    fi
    ldconfig || exit -1
    ln -sf /usr/local/brotli/bin/brotli /usr/bin/brotli
    cd ../..
    rm -rf brotli-${BORTLI_VERSION}
    rm -rf /v${BORTLI_VERSION}.zip
    yum remove -y cmake3 wget unzip gcc
    yum clean all -y
}
install_brotli
