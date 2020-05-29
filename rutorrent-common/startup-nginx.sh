#!/usr/bin/env sh

set -x

chown -R www-data:www-data /app/rutorrent
cp /app/configs/.htpasswd /app/rutorrent/
mkdir -p /app/configs/rutorrent/torrents
chown -R www-data:www-data /app/configs/rutorrent
mkdir -p /app/configs/logs/nginx
chown www-data:www-data /app/configs/logs/nginx

rm -f /etc/nginx/sites-enabled/*

rm -rf /etc/nginx/ssl

rm /app/rutorrent/.htpasswd


# Basic auth enabled by default
site=rutorrent-basic.nginx

# Check if TLS needed
if [ -e /app/configs/nginx.key ] && [ -e /app/configs/nginx.crt ]; then
    mkdir -p /etc/nginx/ssl
    cp /app/configs/nginx.crt /etc/nginx/ssl/
    cp /app/configs/nginx.key /etc/nginx/ssl/
    site=rutorrent-tls.nginx
fi

cp /app/startup/$site /etc/nginx/sites-enabled/
[ -n "$NOIPV6" ] && sed -i 's/listen \[::\]:/#/g' /etc/nginx/sites-enabled/$site
[ -n "$WEBROOT" ] && ln -s /app/rutorrent /app/rutorrent/$WEBROOT

# Check if .htpasswd presents
if [ -e /app/configs/.htpasswd ]; then
    cp /app/configs/.htpasswd /app/rutorrent/ && chmod 755 /app/rutorrent/.htpasswd && chown www-data:www-data /app/rutorrent/.htpasswd
else
# disable basic auth
    sed -i 's/auth_basic/#auth_basic/g' /etc/nginx/sites-enabled/$site
fi

nginx -g "daemon off;"

