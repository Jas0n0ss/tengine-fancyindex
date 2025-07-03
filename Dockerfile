FROM alpine:3.19

LABEL maintainer="Jas0n0ss"
ENV TENGINE_VERSION=3.1.0

# 准备必要路径，防止 pkgconfig 错误
RUN mkdir -p /usr/lib/pkgconfig && chmod 755 /usr/lib/pkgconfig

# 安装依赖（包括 markdown 渲染、fcgiwrap、构建工具等）
RUN apk add --no-cache \
    build-base \
    pcre-dev \
    zlib-dev \
    openssl-dev \
    libxslt-dev \
    gd-dev \
    geoip-dev \
    linux-headers \
    git \
    wget \
    curl \
    bash \
    apache2-utils \
    markdown \
    fcgiwrap \
    tzdata \
    ca-certificates \
    gettext \
 && rm -rf /var/cache/apk/*

# 下载 ngx-fancyindex 模块
RUN git clone https://github.com/aperezdc/ngx-fancyindex.git /usr/src/ngx-fancyindex

# 设置工作目录
WORKDIR /usr/src

# 下载并构建 Tengine（不带 Lua 支持）
RUN wget https://github.com/alibaba/tengine/archive/refs/tags/${TENGINE_VERSION}.tar.gz \
 && tar zxvf ${TENGINE_VERSION}.tar.gz \
 && cd tengine-${TENGINE_VERSION} \
 && ./configure \
    --prefix=/etc/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --sbin-path=/usr/sbin/nginx \
    --with-http_ssl_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_sub_module \
    --with-http_addition_module \
    --with-http_stub_status_module \
    --add-module=/usr/src/ngx-fancyindex \
 && make -j$(nproc) && make install \
 && cd / && rm -rf /usr/src/*

# 创建目录
RUN mkdir -p /app/public /app/ssl /theme /var/www/html

# 安装主题
RUN git clone https://github.com/TheInsomniac/Nginx-Fancyindex-Theme /theme \
 && cp -r /theme/* /var/www/html/

# 拷贝配置模板与入口脚本
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 挂载点和端口
VOLUME ["/app/public", "/app/ssl"]
EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
