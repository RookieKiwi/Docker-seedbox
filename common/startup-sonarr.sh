#!/bin/sh

if [ ! -d /app/seedbox/sonarr ]
then
        echo "/app/seedbox/sonarr does not exist!, Checking for configs directory"
        if [ ! -d /app/configs/sonarr ]
        then
                echo "/app/configs/sonarr does not exist. Creating it."
                mkdir -p /app/configs/sonarr
                ln -s /app/configs/sonarr /app/seedbox/sonarr
                chown -R seedbox:seedbox /app/configs/sonarr
                chown -R seedbox:seedbox /app/seedbox/sonarr
                /app/startup/perm-fixes.sh
        else
                echo "/app/configs/sonarr exists, creating symlinks"
                chown -R seedbox:seedbox /app/configs/sonarr
                chown -R seedbox:seedbox /app/sonarr
                ln -s /app/configs/sonarr /app/seedbox/sonarr
                chown -R seedbox:seedbox /app/seedbox/sonarr
                /app/startup/perm-fixes.sh
        fi
else
        echo "Do not need to relink the sonarr config/seedbox directories."
fi

if [ -f /app/configs/sonarr/config.xml ]
then
        echo "Found an existing sonarr configs. Will not reinitialize."
else
        echo "Need to set up a new sonarr install."
        cp /app/startup/sonarr-config.xml /app/configs/sonarr/config.xml
        chown -R seedbox:seedbox /app/configs/sonarr/config.xml
fi

su --login --command="TERM=xterm /usr/bin/mono /usr/lib/sonarr/bin/Sonarr.exe -nobrowser -data=/app/seedbox/sonarr" seedbox