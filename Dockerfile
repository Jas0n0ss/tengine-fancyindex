FROM alpine:3.19

LABEL maintainer="Jas0n0ss"
ENV TENGINE_VERSION=3.1.0

# Create necessary path to prevent pkgconfig errors
RUN mkdir -p /usr/lib/pkgconfig && chmod 755 /usr/lib/pkgconfig

# Install dependencies (including markdown rendering, fcgiwrap, build tools, etc.)
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

# Clone ngx-fancyindex module
RUN git clone https://github.com/aperezdc/ngx-fancyindex.git /usr/src/ngx-fancyindex

# Set working directory
WORKDIR /usr/src

# Download and build Tengine (without Lua support)
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

# Create necessary directories
RUN mkdir -p /app/public /app/ssl /theme /var/www/html

# Install Fancyindex theme
RUN git clone https://github.com/TheInsomniac/Nginx-Fancyindex-Theme /theme \
 && cp -r /theme/* /var/www/html/

# Copy config template and entrypoint script
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Define volumes and expose ports
VOLUME ["/app/public", "/app/ssl"]
EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
