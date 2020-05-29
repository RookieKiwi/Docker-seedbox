#!/bin/sh

if [ ! -h /app/seedbox/sonarr ]
then
	echo "Linking sonarr config directory to /app/configs/sonarr."
	if [ ! -d /app/configs/sonarr ]
	then
		echo "Did not find /app/configs/sonarr existed. Creating it."
		mkdir -p /app/configs/sonarr
		chown seedbox:seedbox /app/configs/sonarr
	fi
	ln -s /app/configs/sonarr /app/seedbox/sonarr
else
	echo "Do not need to relink the sonarr config directory."
fi

if [ -f /app/configs/sonarr/config.xml ]
then
	echo "Found an existing sonarr configs. Will not reinitialize."
else
	echo "Need to set up a new sonarr install."
    cp /app/startup/sonarr-config.xml /app/configs/sonarr/config.xml
fi

/usr/bin/mono /usr/lib/sonarr/bin/Sonarr.exe -nobrowser -data=/app/seedbox/sonarr