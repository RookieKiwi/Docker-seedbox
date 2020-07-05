#!/bin/sh

if [ ! -d /app/seedbox/lidarr ]
then
        echo "/app/seedbox/lidarr does not exist!, Checking for configs directory"
        if [ ! -d /app/configs/lidarr ]
        then
                echo "/app/configs/lidarr does not exist. Creating it."
                mkdir -p /app/configs/lidarr
                ln -s /app/configs/lidarr /app/seedbox/lidarr
                chown -R seedbox:seedbox /app/configs/lidarr
                chown -R seedbox:seedbox /app/seedbox/lidarr
                /app/startup/perm-fixes.sh
        else
                echo "/app/configs/lidarr exists, creating symlinks"
                chown -R seedbox:seedbox /app/configs/lidarr
                chown -R seedbox:seedbox /app/lidarr
                ln -s /app/configs/lidarr /app/seedbox/lidarr
                chown -R seedbox:seedbox /app/seedbox/lidarr
                /app/startup/perm-fixes.sh
        fi
else
        echo "Do not need to relink the lidarr config/seedbox directories."
fi

if [ -f /app/configs/lidarr/config.xml ]
then
        echo "Found an existing lidarr configs. Will not reinitialize."
else
        echo "Need to set up a new lidarr install."
        cp /app/startup/lidarr-config.xml /app/configs/lidarr/config.xml
        chown -R seedbox:seedbox /app/configs/lidarr/config.xml
fi

su --login --command="TERM=xterm /usr/bin/mono /app/lidarr/Lidarr.exe -nobrowser -data=/app/seedbox/lidarr" seedbox