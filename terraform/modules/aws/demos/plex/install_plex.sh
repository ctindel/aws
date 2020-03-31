#!/bin/bash

wget -q https://downloads.plex.tv/plex-keys/PlexSign.key -O - | apt-key add -
sh -c 'echo "deb https://downloads.plex.tv/repo/deb/ public main $(lsb_release -sc) contrib" >> /etc/apt/sources.list.d/plex.list'

apt-get update
apt-get install -y plexmediaserver

usermod -a -G video amazon

mkdir -p /mnt/ephemeral/media/{fights,movies,tv}
mkdir -p /mnt/ephemeral/data/plex/transcoder

chgrp -R video /mnt/ephemeral
chmod -R 775 /mnt/ephemeral
chmod -R a+s /mnt/ephemeral

chown -R plex:plex /mnt/efs/plex/plex

# Restore the plex config file and databases directory (for library configs)
cp -f /mnt/efs/plex/plex/backup/Preferences.xml /var/lib/plexmediaserver/Library/Application\ Support/Plex\ Media\ Server/Preferences.xml
cp -r /mnt/efs/plex/plex/backup/Databases /var/lib/plexmediaserver/Library/Application\ Support/Plex\ Media\ Server/Plug-in\ Support/
chown -R plex:plex /var/lib/plexmediaserver/
chmod 600 /var/lib/plexmediaserver/Library/Application\ Support/Plex\ Media\ Server/Preferences.xml

systemctl stop plexmediaserver
systemctl start plexmediaserver
systemctl enable plexmediaserver

cp -a /mnt/efs/plex/srv /home/amazon
chown -R amazon:amazon /home/amazon/srv

docker-compose -f /home/amazon/srv/sabnzbd/docker-compose.yml up -d
docker-compose -f /home/amazon/srv/synclounge/docker-compose.yml up -d

# Restore any downloaded media
rsync -r /mnt/efs/plex/media/ /mnt/ephemeral/media/ 
