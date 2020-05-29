#!/bin/sh

if [ ! -d /app/seedbox/radarr ]
then
	echo "Linking radarr config directory to /app/configs/radarr."
	if [ ! -d /app/configs/radarr ]
	then
		echo "Did not find /app/configs/radarr existed. Creating it."
		mkdir -p /app/configs/radarr
		chown seedbox:seedbox /app/configs/radarr
		ln -s /app/configs/radarr /app/seedbox/radarr
	fi
else
	echo "Do not need to relink the radarr config directory."
fi

if [ -f /app/configs/radarr/config.xml ]
then
	echo "Found an existing radarr configs. Will not reinitialize."
else
	echo "Need to set up a new radarr install."
    cp /app/startup/radarr-config.xml /app/configs/radarr/config.xml
fi

/usr/bin/mono /app/radarr/Radarr.exe -nobrowser -data=/app/seedbox/radarr