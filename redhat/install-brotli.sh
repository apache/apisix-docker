install_brotli () {
    yum install -y brotli libbrotli
    link_brotli_sonames
    yum clean all -y
}

# brotli-ffi calls ffi.load("brotlienc"), which resolves the unversioned
# soname. Distros ship that symlink in brotli-devel, so create it here
# instead of pulling build headers into the runtime image.
link_brotli_sonames () {
    local lib so dir
    for lib in brotlicommon brotlidec brotlienc; do
        so=$(ldconfig -p | awk -v n="lib${lib}.so.1" '$1 == n { print $NF; exit }')
        if [ -z "${so}" ]; then
            echo "lib${lib}.so.1 not found after install" >&2
            exit 1
        fi
        dir=$(dirname "${so}")
        ln -sf "lib${lib}.so.1" "${dir}/lib${lib}.so"
    done
    ldconfig
}

install_brotli
