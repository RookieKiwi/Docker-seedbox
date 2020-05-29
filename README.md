# Docker-seedbox
I created Docker-seedbox for my own personal use but thought perhaps other people would benefit from it, The idea is a docker container with all your standard seedbox applications installed and built in, below is a list of installed applications and there details

###### ruTorrent
ruTorrent is installed on port 31337 (non-ssl) or 31343 (with ssl) by default, i have also added all the standard plugins which people use with ruTorrent including the autodl-irssi plugin

###### SABnzbdPlus
SABnzbd is installed on port 31338 by default, SABnzbd is a cross-platform binary newsreader. It makes downloading from Usenet easy by automating the whole thing. You give it an NZB file or an RSS feed, it does the rest. Has a web-browser based UI and an API for 3rd-party apps. Ideal for servers too.

###### Sonarr
Sonarr is installed on port 31339 by default, Sonarr is a PVR for Usenet and BitTorrent users. It can monitor multiple RSS feeds for new episodes of your favorite shows and will grab, sort and rename them. It can also be configured to automatically upgrade the quality of files already downloaded when a better quality format becomes available.

###### Radarr
Radarr is installed on port 31340 by default, Radarr is an independent fork of Sonarr reworked for automatically downloading movies via Usenet and BitTorrent.
The project was inspired by other Usenet/BitTorrent movie downloaders such as CouchPotato.

###### Lidarr
Lidarr is installed on port 31341, Lidarr is a music collection manager for Usenet and BitTorrent users. It can monitor multiple RSS feeds for new tracks from your favorite artists and will grab, sort and rename them. It can also be configured to automatically upgrade the quality of files already downloaded when a better quality format becomes available.

###### Jackett
Jacket is installed on port 31342, Jackett works as a proxy server: it translates queries from apps (Sonarr, Radarr, SickRage, CouchPotato, Mylar, Lidarr, DuckieTV, qBittorrent, Nefarious etc.) into tracker-site-specific http queries, parses the html response, then sends results back to the requesting software. This allows for getting recent uploads (like RSS) and performing searches. Jackett is a single repository of maintained indexer scraping & translation logic - removing the burden from other apps.

## Configuration of Ports and Directories

Container location: /app/downloads
Where files will be downloaded to

Container location: /app/configs
Where configuration files will be generated to