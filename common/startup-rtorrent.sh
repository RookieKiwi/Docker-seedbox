#!/bin/sh
if [ ! -h /app/configs/rtorrent ]
then
    mkdir -p /app/configs/rtorrent/session 
    mkdir -p /app/downloads/watch
    mkdir -p /app/configs/logs/rtorrent
    chown -R seedbox:seedbox /app/configs/rtorrent
    chown -R seedbox:seedbox /app/seedbox
    chown -R seedbox:seedbox /app/configs/logs/rtorrent

fi

if [ ! -e /app/configs/rtorrent/rtorrent.rc ]; then
    cp /app/startup/rtorrent.rc /app/configs/rtorrent/rtorrent.rc
    ln -s /app/configs/rtorrent/rtorrent.rc /app/seedbox/.rtorrent.rc
fi

rm -f /app/configs/rtorrent/session/rtorrent.lock
ln -s /app/configs/rtorrent/rtorrent.rc /app/seedbox/.rtorrent.rc

# run
su --login --command="TERM=xterm rtorrent" seedbox 
