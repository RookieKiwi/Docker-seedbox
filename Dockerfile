FROM ubuntu:16.04
USER root

# version labels
ARG VERSION
ARG DEBIAN_FRONTEND="noninteractive"
LABEL build_version="Docker-seedbox version ${VERSION} by RookieKiwi"
LABEL maintainer="RookieKiwi"
ENV HOME="/config" PYTHONIOENCODING=utf-8

# copy common files for install
COPY common/ /app/installer-common/

RUN \
    echo "*** Running container updates, adding repos and doing basic installs ***" && \
    apt-get update && \
    apt-get install -y dirmngr gnupg apt-transport-https ca-certificates && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
    echo "deb https://download.mono-project.com/repo/ubuntu stable-xenial main" | tee /etc/apt/sources.list.d/mono-official-stable.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 2009837CBFFD68F45BC180471F4F90DE2A9B4BF8 && \
    echo "deb https://apt.sonarr.tv/ubuntu xenial main" | tee /etc/apt/sources.list.d/sonarr.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:11371 --recv-keys 0x98703123E0F52B2BE16D586EF13930B14BB9F05F && \
    echo "deb http://ppa.launchpad.net/jcfp/nobetas/ubuntu xenial main" | tee /etc/apt/sources.list.d/sabnzbd.list && \
    echo "deb http://ppa.launchpad.net/jcfp/sab-addons/ubuntu xenial main" | tee /etc/apt/sources.list.d/sabnzbd.list && \
    apt-get update && apt-get install -y git wget unzip unrar libssl1.0
 
RUN \
    echo "*** Installing PIP / Python and Cloudscraper ***" && \
    apt-get install -y libarchive-zip-perl libjson-perl libxml-libxml-perl python3-pip python-pip && \
    /usr/bin/python3 -m pip install --upgrade pip &&\
    /usr/bin/python -m pip install --upgrade pip &&\
    pip3 install cloudscraper &&\
    pip install cloudscraper

RUN \
    echo "*** Installing PHP, Web Services and creating seedbox user ***" && \
    apt-get install -y curl php-fpm php-cli php-geoip php-mbstring php-zip nginx ffmpeg php-xml && \
    mkdir -p /app/seedbox && adduser --disabled-password --home /app/seedbox -q --gecos "" seedbox && \
    chown -R seedbox:seedbox /app/seedbox

RUN \
    echo "*** Installing remaining components for ruTorrent and plugins ***" && \
    apt-get install -y git rtorrent mediainfo supervisor irssi sox && \
    mkdir /app/startup && \
    cp /app/installer-common/rutorrent-*.nginx /app/startup/ && \
    cd /app && \
    git clone https://github.com/Novik/ruTorrent.git rutorrent

RUN \
    echo "*** Software installed, configuring applications and setting up directories ***" && \
    cd / && \
    cp /app/installer-common/config.php /app/installer-common/startup-rtorrent.sh /app/installer-common/startup-*.sh /app/installer-common/*config.xml /app/installer-common/sab*.ini /app/installer-common/rtorrent.rc /app/installer-common/perm-fixes.sh /app/startup/ && \
    cp /app/installer-common/supervisord.conf /etc/supervisor/conf.d/ && \
    chmod +x /app/startup/*.sh && \
    ln -s /config /app/configs && \
    sed -i 's/\/var\/log/\/app\/configs\/logs/g' /etc/nginx/nginx.conf

RUN \
    echo "**** Install Jackett ****" && \
    mkdir /app/jackett && cd /tmp && wget https://github.com/Jackett/Jackett/releases/download/v0.16.788/Jackett.Binaries.LinuxAMDx64.tar.gz -O /tmp/jackett.tgz && \
    tar xf /tmp/jackett.tgz -C /app/jackett --strip-components=1 && \
    chown -R seedbox:seedbox /app/jackett

 RUN \
    echo "*** Install Radarr ***" && \
    cd /tmp && apt-get install mono-devel -y && \
    wget https://github.com/Radarr/Radarr/releases/download/v0.2.0.1480/Radarr.develop.0.2.0.1480.linux.tar.gz -O radarr.tgz && \
    tar -xvzf radarr.tgz && \
    mv Radarr /app/radarr && \
    chown -R seedbox:seedbox /app/radarr

RUN \
    echo "*** Install Lidarr ***" && \
    cd /tmp && wget https://github.com/lidarr/Lidarr/releases/download/v0.7.1.1381/Lidarr.master.0.7.1.1381.linux.tar.gz -O lidarr.tgz && \
    tar xzvf lidarr.tgz && \
    mv Lidarr /app/lidarr && \
    chown -R seedbox:seedbox /app/lidarr

RUN \
    echo "*** Install Sonarr ***" && \
    apt-get install sonarr sqlite3 libmediainfo-dev -y
    
# RUN \
#    echo "*** Install Bazarr ***" && \
#    cd /app && git clone https://github.com/morpheus65535/bazarr.git && \
#    cd bazarr && pip install -r requirements.txt && \

RUN \
    echo "*** Install SABNZBDPLUS ***" && \
    /usr/bin/python -m pip install apprise chardet pynzb requests sabyenc cryptography markdown --upgrade && \
    /usr/bin/python3 -m pip install apprise chardet pynzb requests sabyenc cryptography markdown --upgrade && \
    apt-get install -y sabnzbdplus python-cryptography par2-tbb

RUN \
    echo "*** Time to run a final clean up ***" && \
    apt-get clean -y && \
    rm -rf \
        /app/installer-common \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* 

# PORTs 31337/rutorrent 31338/sabnzbdplus 31339/sonarr 31340/radarr 31341/lidarr 31342/jackett 31343/rutorrentssl 31344/sci 31345/dht 31346/torrents

EXPOSE 31337 31338 31339 31340 31341 31342 31343 31344 31345 31346
VOLUME /app/downloads /app/configs


CMD ["supervisord"]
