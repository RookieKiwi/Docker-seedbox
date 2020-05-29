#!/bin/sh

su --login --command="TERM=xterm /app/jackett/jackett --NoRestart -p 31342 -d /app/seedbox/jackett" seedbox