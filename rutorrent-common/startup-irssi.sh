#!/usr/bin/env sh

sleep 5

# Set up .autodl dir, and allow for configs to be saved.
if [ ! -h /app/seedbox/.autodl ]
then
	echo "Linking autodl config directory to /app/configs/autodl."
	if [ ! -d /app/configs/autodl ]
	then
		echo "Did not find /app/configs/autodl existed. Creating it."
		mkdir /app/configs/autodl
		chown seedbox:seedbox /app/configs/autodl
	fi
	ln -s /app/configs/autodl /app/seedbox/.autodl
else
	echo "Do not need to relink the autodl config directory."
fi

if [ -f /app/configs/autodl/autodl.cfg ]
then
	echo "Found an existing autodl configs. Will not reinitialize."
	irssi_port=$(grep gui-server-port /app/configs/autodl/autodl2.cfg | awk '{print $3}')
	irssi_pass=$(grep gui-server-password /app/configs/autodl/autodl2.cfg | awk '{print $3}')
else
	echo "Need to set up a new autodl install."

	irssi_pass=$(perl -le 'print map {(a..z,A..Z,0..9)[rand 62] } 0..pop' 15)
	irssi_port=$((RANDOM%64025+1024))
	
	echo "Creating necessary configuration files ... "
	touch /app/configs/autodl/autodl.cfg
	cat >/app/configs/autodl/autodl2.cfg<<ADC
[options]
gui-server-port = ${irssi_port}
gui-server-password = ${irssi_pass}
ADC
	chown -R seedbox:seedbox /app/configs/autodl
fi



# Set up .irssi scripts.
if [ ! -d /app/seedbox/.irssi ]
then
	echo "Creating necessary directory structure for irssi and downloading files ... "
	mkdir -p /app/seedbox/.irssi/scripts/autorun && cd /app/seedbox/.irssi/scripts || (echo "mkdir failed ... " && exit 1)
	curl -sL http://git.io/vlcND | grep -Po '(?<="browser_download_url": ")(.*-v[\d.]+.zip)' | xargs wget --quiet -O autodl-irssi.zip
	unzip -o autodl-irssi.zip >/dev/null 2>&1
	rm autodl-irssi.zip
	cp autodl-irssi.pl autorun/
	chown -R rtorrent:rtorrent /app/seedbox/.irssi
	sed -i -e 's/1.86/1.84/g' /app/seedbox/.irssi/scripts/AutodlIrssi/SslSocket.pm
else
	echo "Found irssi scripts are installed. Skipping install."
fi



# Install the web plugin.
if [ ! -d /app/rutorrent/plugins/autodl-irssi ]	
then
	echo "Installing web plugin portion."
	# Web plugin setup.
	cd /app/rutorrent/plugins/
	git clone https://github.com/autodl-community/autodl-rutorrent.git autodl-irssi > /dev/null 2>&1
	cd autodl-irssi
	cp _conf.php conf.php
	sed -i "s/autodlPort = 0;/autodlPort = ${irssi_port};/" conf.php
	sed -i "s/autodlPassword = \"\";/autodlPassword = \"${irssi_pass}\";/" conf.php
else
	echo "Found web plugin portion is already installed."
fi

echo "Starting up irssi."
su --login --command="TERM=xterm irssi" seedbox

