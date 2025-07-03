#!/bin/sh

# Generate nginx configuration
envsubst '${SSL_LISTEN} ${SSL_CERTS}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# HTTP Basic Auth (optional)
if [ "$HTTP_AUTH" = "on" ]; then
  htpasswd -cb /etc/nginx/.htpasswd "$HTTP_USERNAME" "$HTTP_PASSWD"
  echo "HTTP Basic Auth enabled"
else
  sed -i '/auth_basic/d' /etc/nginx/nginx.conf
  echo "HTTP Basic Auth disabled"
fi

# SSL support (optional)
if [ "$ENABLE_SSL" != "on" ]; then
  sed -i '/listen 443 ssl/d' /etc/nginx/nginx.conf
  sed -i '/ssl_certificate/d' /etc/nginx/nginx.conf
  sed -i '/ssl_certificate_key/d' /etc/nginx/nginx.conf
  echo "SSL disabled"
else
  echo "SSL enabled"
fi

# Start fcgiwrap (run in background)
spawn-fcgi -s /var/run/fcgiwrap.socket -M 766 /usr/sbin/fcgiwrap

# Start nginx (run in foreground)
exec "$@"
