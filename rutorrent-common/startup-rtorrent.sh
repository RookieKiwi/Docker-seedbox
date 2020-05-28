#!/usr/bin/env sh

set -x

# set rtorrent user and group id
RT_UID=${USR_ID:=1000}
RT_GID=${GRP_ID:=1000}

# update uids and gids
groupadd -g $RT_GID rtorrent
useradd -u $RT_UID -g $RT_GID -d /home/rtorrent -m -s /bin/bash rtorrent

# arrange dirs and configs
mkdir -p /app/configs/rtorrent
mkdir -p /app/configs/rtorrent/session 
mkdir -p /app/downloads/watch
mkdir -p /app/configs/logs/rtorrent
if [ ! -e /app/configs/rtorrent/rtorrent.rc ]; then
    cp /app/startup/rtorrent.rc /app/configs/rtorrent/rtorrent.rc
fi
ln -s /app/configs/rtorrent/rtorrent.rc /home/rtorrent/.rtorrent.rc
chown -R rtorrent:rtorrent /app/configs/rtorrent
chown -R rtorrent:rtorrent /home/rtorrent
chown -R rtorrent:rtorrent /app/configs/logs/rtorrent

rm -f /app/configs/rtorrent/session/rtorrent.lock

# run
su --login --command="TERM=xterm rtorrent" rtorrent 

