#!/bin/sh

if [ ! -h /app/seedbox/sab ]
then
	echo "Linking sab config directory to /app/configs/sab."
	if [ ! -d /app/configs/sab ]
	then
		echo "Did not find /app/configs/sab existed. Creating it."
		mkdir -p /app/configs/sab
		chown seedbox:seedbox /app/configs/sab
	fi
	ln -s /app/configs/sab /app/seedbox/sab
else
	echo "Do not need to relink the sab config directory."
fi

if [ -f /app/configs/sab/sabnzbd.ini ]
then
	echo "Found an existing sab configs. Will not reinitialize."
else
	echo "Need to set up a new sab install."
    cp /app/startup/sabnzbd.ini /app/configs/sab/sabnzbd.ini
fi

/usr/bin/sabnzbdplus -f /app/seedbox -s 0.0.0.0:31338