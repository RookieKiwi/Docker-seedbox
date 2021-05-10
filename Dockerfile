FROM ubuntu:16.04
USER root

# version labels
ARG VERSION
ARG DEBIAN_FRONTEND="noninteractive"
LABEL build_version="Docker-seedbox version ${VERSION} by RookieKiwi"
LABEL maintainer="RookieKiwi"
ENV HOME="/config" PYTHONIOENCODING=utf-8 PYTHONUNBUFFERED=1

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
    apt-get update && apt-get install -y git wget unzip libssl1.0 p7zip software-properties-common python-software-properties && \
    add-apt-repository ppa:deadsnakes/ppa && apt-get update && \
    cd /tmp && wget https://www.rarlab.com/rar/rarlinux-x64-6.0.0.tar.gz && tar xzvf rarlinux-x64-6.0.0.tar.gz && cp rar/rar /usr/bin && cp rar/unrar /usr/bin && rm -rf rar*
 
RUN \
    echo "*** Installing PIP / Python and Cloudscraper ***" && \
    apt-get install -y libarchive-zip-perl libjson-perl libxml-libxml-perl python3.6 python3.6-dev python3.6-venv python3-pip python-pip curl && \
    curl https://bootstrap.pypa.io/pip/3.5/get-pip.py -o get-pip.py &&\
    /usr/bin/python3.6 get-pip.py --force-reinstall &&\
    rm get-pip.py &&\
    pip install --user --upgrade pip &&\
    pip3 install cloudscraper &&\
    pip install cloudscraper

RUN \
    echo "*** Installing PHP, Web Services and creating seedbox user ***" && \
    apt-get install -y php-fpm php-cli php-geoip php-mbstring php-zip nginx ffmpeg php-xml && \
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
    cp /app/installer-common/seedbox.conf /etc/supervisor/conf.d/ && \
    cp /app/installer-common/supervisord.conf /etc/supervisor/ && \
    chmod +x /app/startup/*.sh && \
    ln -s /config /app/configs && \
    sed -i 's/\/var\/log/\/app\/configs\/logs/g' /etc/nginx/nginx.conf

RUN \
    echo "**** Install Jackett ****" && \
    mkdir /app/jackett && cd /tmp && wget https://github.com/Jackett/Jackett/releases/download/v0.17.677/Jackett.Binaries.LinuxAMDx64.tar.gz -O /tmp/jackett.tgz && \
    tar xf /tmp/jackett.tgz -C /app/jackett --strip-components=1 && \
    chown -R seedbox:seedbox /app/jackett

 RUN \
    echo "*** Install Radarr ***" && \
    cd /tmp && apt-get install mono-devel -y && \
    wget https://github.com/Radarr/Radarr/releases/download/v3.1.1.4954/Radarr.master.3.1.1.4954.linux-core-x64.tar.gz -O radarr.tgz && \
    tar -xvzf radarr.tgz && \
    mv Radarr /app/radarr && \
    chown -R seedbox:seedbox /app/radarr

RUN \
    echo "*** Install Lidarr ***" && \
    cd /tmp && wget https://github.com/acoustid/chromaprint/releases/download/v1.5.0/chromaprint-fpcalc-1.5.0-linux-x86_64.tar.gz -O fpcalc.tgz && tar xzvf fpcalc.tgz && cp chromaprint-fpcalc-1.5.0-linux-x86_64/fpcalc /usr/bin && \
    cd /tmp && wget https://github.com/lidarr/Lidarr/releases/download/v0.8.1.2135/Lidarr.master.0.8.1.2135.linux-core-x64.tar.gz -O lidarr.tgz && \
    tar xzvf lidarr.tgz && \
    mv Lidarr /app/lidarr && \
    chown -R seedbox:seedbox /app/lidarr

RUN \
    echo "*** Install Sonarr ***" && \
    apt-get install sonarr sqlite3 libmediainfo-dev -y

RUN \
    echo "*** Install SABNZBDPLUS ***" && \
    /usr/bin/python3.6 -m pip install setuptools --upgrade && \
    /usr/bin/python3.6 -m pip install apprise chardet pynzb requests sabyenc cryptography markdown wheel feedparser cherrypy portend gntp pyopenssl --upgrade && \
    apt-get install -y libffi-dev libssl-dev python-cryptography par2-tbb p7zip-full language-pack-en && \
    cd /app && \
    git clone https://github.com/sabnzbd/sabnzbd.git && \
    chown -R seedbox:seedbox sabnzbd && \
    cd sabnzbd && \
    update-locale LANG=en_US.UTF-8 LANGUAGE && \
    python3.6 -m pip install -r requirements.txt -U

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

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
