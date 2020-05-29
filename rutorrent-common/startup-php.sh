#!/usr/bin/env sh

set -x

if [ ! -e /app/configs/config.php ]; then
    cp /app/startup/config.php /app/configs/config.php
fi
rm -rf /app/rutorrent/conf/config.php
ln -s /app/configs/config.php /app/rutorrent/conf/config.php

MEM=${PHP_MEM:=256M}

sed -i 's/memory_limit.*$/memory_limit = '$MEM'/g' /etc/php/7.0/fpm/php.ini

mkdir /run/php
php-fpm7.0 --nodaemonize

