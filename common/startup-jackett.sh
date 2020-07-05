#!/bin/sh

if [ ! -d /app/seedbox/jackett ]
then
        echo "/app/seedbox/jackett does not exist!, Checking for configs directory"
        if [ ! -d /app/configs/jackett ]
        then
                echo "/app/configs/jackett does not exist. Creating it."
                mkdir -p /app/configs/jackett
                ln -s /app/configs/jackett /app/seedbox/jackett
                chown -R seedbox:seedbox /app/configs/jackett
                chown -R seedbox:seedbox /app/seedbox/jackett
                /app/startup/perm-fixes.sh
        else
                echo "/app/configs/jackett exists, creating symlinks"
                chown -R seedbox:seedbox /app/configs/jackett
                chown -R seedbox:seedbox /app/jackett
                ln -s /app/configs/jackett /app/seedbox/jackett
                chown -R seedbox:seedbox /app/seedbox/jackett
                /app/startup/perm-fixes.sh
        fi
else
        echo "Do not need to relink the jackett config/seedbox directories."
fi

su --login --command="TERM=xterm /app/jackett/jackett --NoRestart -p 31342 -d /app/seedbox/jackett" seedbox