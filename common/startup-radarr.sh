#!/bin/sh

if [ ! -d /app/seedbox/radarr ]
then
        echo "/app/seedbox/radarr does not exist!, Checking for configs directory"
        if [ ! -d /app/configs/radarr ]
        then
                echo "/app/configs/radarr does not exist. Creating it."
                mkdir -p /app/configs/radarr
                ln -s /app/configs/radarr /app/seedbox/radarr
                chown -R seedbox:seedbox /app/configs/radarr
                chown -R seedbox:seedbox /app/seedbox/radarr
                /app/startup/perm-fixes.sh
        else
                echo "/app/configs/radarr exists, creating symlinks"
                chown -R seedbox:seedbox /app/configs/radarr
                chown -R seedbox:seedbox /app/radarr
                ln -s /app/configs/radarr /app/seedbox/radarr
                chown -R seedbox:seedbox /app/seedbox/radarr
                /app/startup/perm-fixes.sh
        fi
else
        echo "Do not need to relink the radarr config/seedbox directories."
fi

if [ -f /app/configs/radarr/config.xml ]
then
        echo "Found an existing radarr configs. Will not reinitialize."
else
        echo "Need to set up a new radarr install."
    	cp /app/startup/radarr-config.xml /app/configs/radarr/config.xml
        chown -R seedbox:seedbox /app/configs/radarr/config.xml
fi

su --login --command="TERM=xterm /app/radarr/Radarr -nobrowser -data=/app/seedbox/radarr" seedbox