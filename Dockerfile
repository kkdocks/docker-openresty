FROM alpine:3.10

# Docker Build Arguments
ARG RESTY_VERSION="1.15.8.2"
ARG RESTY_OPENSSL_VERSION="1.1.1c"

LABEL maintainer="Nekoimi <i@sakuraio.com>" resty_version="${RESTY_VERSION}" resty_openssl_version="${RESTY_OPENSSL_VERSION}"

ARG LUAROCKS_VERSION="3.2.0"
ARG RESTY_PCRE_VERSION="8.43"
ARG RESTY_J="1"
ARG RESTY_CONFIG_OPTIONS="\
    --with-compat \
    --with-file-aio \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_geoip_module=dynamic \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_image_filter_module=dynamic \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-http_xslt_module=dynamic \
    --with-ipv6 \
    --with-mail \
    --with-mail_ssl_module \
    --with-md5-asm \
    --with-pcre-jit \
    --with-sha1-asm \
    --with-stream \
    --with-stream_ssl_module \
    --with-threads \
    "
ARG RESTY_CONFIG_OPTIONS_MORE=""
ARG RESTY_LUAJIT_OPTIONS="--with-luajit-xcflags='-DLUAJIT_NUMMODE=2 -DLUAJIT_ENABLE_LUA52COMPAT'"

ARG RESTY_ADD_PACKAGE_BUILDDEPS=""
ARG RESTY_ADD_PACKAGE_RUNDEPS=""
ARG RESTY_EVAL_PRE_CONFIGURE=""
ARG RESTY_EVAL_POST_MAKE=""

# These are not intended to be user-specified
ARG _RESTY_CONFIG_DEPS="--with-pcre \
    --with-cc-opt='-DNGX_LUA_ABORT_AT_PANIC -I/usr/local/openresty/pcre/include -I/usr/local/openresty/openssl/include' \
    --with-ld-opt='-L/usr/local/openresty/pcre/lib -L/usr/local/openresty/openssl/lib -Wl,-rpath,/usr/local/openresty/pcre/lib:/usr/local/openresty/openssl/lib' \
    "

RUN set -eux; \
        echo ">>>>>>>>>>>>>>>>>>>>>>>>>> 添加 www-data " ; \
    	addgroup -g 82 -S www-data; \
    	adduser -u 82 -D -S -G www-data www-data ; \
    	echo ">>>>>>>>>>>>>>>>>>>>>>>>>> 更换国内源 " ; \
    	sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories ; \
    	apk update ; \
        apk add --no-cache --virtual .build-deps \
        build-base \
        coreutils \
        gd-dev \
        geoip-dev \
        libxslt-dev \
        linux-headers \
        make \
        perl-dev \
        readline-dev \
        zlib-dev \
        tzdata \
        unzip \
        ${RESTY_ADD_PACKAGE_BUILDDEPS} \
    && apk add --no-cache \
        gd \
        geoip \
        libgcc \
        libxslt \
        zlib \
        curl \
        bash \
        openssl \
        ${RESTY_ADD_PACKAGE_RUNDEPS} \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && cd /tmp \
    && if [ -n "${RESTY_EVAL_PRE_CONFIGURE}" ]; then eval $(echo ${RESTY_EVAL_PRE_CONFIGURE}); fi \
    && curl -fSL https://www.openssl.org/source/openssl-${RESTY_OPENSSL_VERSION}.tar.gz -o openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
    && tar xzf openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
    && cd openssl-${RESTY_OPENSSL_VERSION} \
    && if [ $(echo ${RESTY_OPENSSL_VERSION} | cut -c 1-5) = "1.1.1" ] ; then \
        echo 'patching OpenSSL 1.1.1 for OpenResty' \
        && curl -s https://raw.githubusercontent.com/openresty/openresty/master/patches/openssl-1.1.1c-sess_set_get_cb_yield.patch | patch -p1 ; \
    fi \
    && if [ $(echo ${RESTY_OPENSSL_VERSION} | cut -c 1-5) = "1.1.0" ] ; then \
        echo 'patching OpenSSL 1.1.0 for OpenResty' \
        && curl -s https://raw.githubusercontent.com/openresty/openresty/ed328977028c3ec3033bc25873ee360056e247cd/patches/openssl-1.1.0j-parallel_build_fix.patch | patch -p1 \
        && curl -s https://raw.githubusercontent.com/openresty/openresty/master/patches/openssl-1.1.0d-sess_set_get_cb_yield.patch | patch -p1 ; \
    fi \
    && ./config \
      no-threads shared zlib -g \
      enable-ssl3 enable-ssl3-method \
      --prefix=/usr/local/openresty/openssl \
      --libdir=lib \
      -Wl,-rpath,/usr/local/openresty/openssl/lib \
    && make -j${RESTY_J} \
    && make -j${RESTY_J} install_sw \
    && cd /tmp \
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
    && make -j${RESTY_J} install \
    && cd /tmp \
    && curl -fSL https://openresty.org/download/openresty-${RESTY_VERSION}.tar.gz -o openresty-${RESTY_VERSION}.tar.gz \
    && tar xzf openresty-${RESTY_VERSION}.tar.gz \
    && cd /tmp/openresty-${RESTY_VERSION} \
    && eval ./configure -j${RESTY_J} ${_RESTY_CONFIG_DEPS} ${RESTY_CONFIG_OPTIONS} ${RESTY_CONFIG_OPTIONS_MORE} ${RESTY_LUAJIT_OPTIONS} \
    && make -j${RESTY_J} \
    && make -j${RESTY_J} install \
    && if [ -n "${RESTY_EVAL_POST_MAKE}" ]; then eval $(echo ${RESTY_EVAL_POST_MAKE}); fi \
    && cd /tmp \
    && echo ">>>>>>>>>>>>>>>>>>> install luarocks, version: ${LUAROCKS_VERSION}" \
    && curl -fSL https://luarocks.github.io/luarocks/releases/luarocks-${LUAROCKS_VERSION}.tar.gz -o luarocks-${LUAROCKS_VERSION}.tar.gz \
    && tar xzf luarocks-${LUAROCKS_VERSION}.tar.gz \
    && cd /tmp/luarocks-${LUAROCKS_VERSION} \
    && ./configure --prefix=/usr/local/openresty/luajit/ \
           --with-lua=/usr/local/openresty/luajit/ \
           --lua-suffix=jit \
           --with-lua-include=/usr/local/openresty/luajit/include/luajit-2.1 \
    && make -j${RESTY_J} \
    && make -j${RESTY_J} install \
    && ln -s /usr/local/openresty/luajit/bin/luarocks /usr/local/bin/ \
    && echo ">>>>>>>>>>>>>>>>>>> install lua-resty-auto-ssl " \
    && luarocks install lua-resty-auto-ssl --tree=/usr/local/openresty/luajit \
    # /usr/local/openresty/lualib/resty/share/lua/5.1
    # /usr/local/openresty/luajit/share/lua/5.1/resty/auto-ssl.lua
    && mkdir /etc/resty-auto-ssl && chown www-data /etc/resty-auto-ssl \
    && echo ">>>>>>>>>>>>>>>>>>> 生成自签证书 " \
    && openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
          -subj '/CN=sni-support-required-for-valid-ssl' \
          -keyout   /etc/ssl/resty-auto-ssl-fallback.key \
          -out      /etc/ssl/resty-auto-ssl-fallback.crt \
    && openssl dhparam -out /etc/ssl/resty-auto-ssl-dhparam.pem 2048 \
    && echo ">>>>>>>>>>>>>>>>>>> clear install paks " \
    && rm -rf /tmp/* \
    && apk del .build-deps \
    && mkdir -p /var/run/openresty \
    && ln -sf /dev/stdout /usr/local/openresty/nginx/logs/access.log \
    && ln -sf /dev/stderr /usr/local/openresty/nginx/logs/error.log

# Add additional binaries into PATH for convenience
ENV PATH=$PATH:/usr/local/openresty/luajit/bin:/usr/local/openresty/nginx/sbin:/usr/local/openresty/bin

EXPOSE 80

STOPSIGNAL SIGQUIT

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]