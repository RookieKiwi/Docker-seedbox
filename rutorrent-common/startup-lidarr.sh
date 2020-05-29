#!/bin/sh

if [ ! -h /app/seedbox/lidarr ]
then
	echo "Linking lidarr config directory to /app/configs/lidarr."
	if [ ! -d /app/configs/lidarr ]
	then
		echo "Did not find /app/configs/lidarr existed. Creating it."
		mkdir -p /app/configs/lidarr
		chown seedbox:seedbox /app/configs/lidarr
	fi
	ln -s /app/configs/lidarr /app/seedbox/lidarr
else
	echo "Do not need to relink the lidarr config directory."
fi

if [ -f /app/configs/lidarr/config.xml ]
then
	echo "Found an existing lidarr configs. Will not reinitialize."
else
	echo "Need to set up a new lidarr install."
    cp /app/startup/lidarr-config.xml /app/configs/lidarr/config.xml
fi

/usr/bin/mono /app/lidarr/Lidarr.exe -nobrowser -data=/app/seedbox/lidarr