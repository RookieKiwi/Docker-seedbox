#!/bin/sh

if [ ! -d /app/seedbox/sab ]
then
        echo "/app/seedbox/sab does not exist!, Checking for configs directory"
        if [ ! -d /app/configs/sab ]
        then
                echo "/app/configs/sab does not exist. Creating it."
                mkdir -p /app/configs/sab
                ln -s /app/downloads /app/seedbox/sab/Downloads
                ln -s /app/configs/sab /app/seedbox/sab
                chown -R seedbox:seedbox /app/configs/sab
                chown -R seedbox:seedbox /app/seedbox/sab
		/app/startup/perm-fixes.sh
        else
                echo "/app/configs/sab exists, creating symlinks"
                ln -s /app/downloads /app/seedbox/sab/Downloads
                chown -R seedbox:seedbox /app/configs/sab
                chown -R seedbox:seedbox /app/sab
                ln -s /app/configs/sab /app/seedbox/sab
                chown -R seedbox:seedbox /app/seedbox/sab
		/app/startup/perm-fixes.sh
        fi
else
        echo "Do not need to relink the sab config/seedbox directories."
fi

if [ -f /app/configs/sab/sabnzbd.ini ]
then
	echo "Found an existing sab configs. Will not reinitialize."
else
	echo "Need to set up a new sab install."
        cp /app/startup/sabnzbd.ini /app/configs/sab/sabnzbd.ini
	chown -R seedbox:seedbox /app/configs/sab/sabnzbd.ini
fi

su --login --command="TERM=xterm /usr/bin/sabnzbdplus -f /app/seedbox/sab -s 0.0.0.0:31338" seedbox