#!/bin/sh

# 生成 nginx 配置
envsubst '${SSL_LISTEN} ${SSL_CERTS}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# HTTP Basic Auth（可选）
if [ "$HTTP_AUTH" = "on" ]; then
  htpasswd -cb /etc/nginx/.htpasswd "$HTTP_USERNAME" "$HTTP_PASSWD"
  echo "HTTP Basic Auth enabled"
else
  sed -i '/auth_basic/d' /etc/nginx/nginx.conf
  echo "HTTP Basic Auth disabled"
fi

# SSL 支持（可选）
if [ "$ENABLE_SSL" != "on" ]; then
  sed -i '/listen 443 ssl/d' /etc/nginx/nginx.conf
  sed -i '/ssl_certificate/d' /etc/nginx/nginx.conf
  sed -i '/ssl_certificate_key/d' /etc/nginx/nginx.conf
  echo "SSL disabled"
else
  echo "SSL enabled"
fi

# 启动 fcgiwrap（后台运行）
spawn-fcgi -s /var/run/fcgiwrap.socket -M 766 /usr/sbin/fcgiwrap

# 启动 nginx（前台）
exec "$@"
