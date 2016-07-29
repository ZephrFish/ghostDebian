#!/bin/bash

if [[ `whoami` != root ]]; then
echo "This script must be run as root."
exit 1
fi

# Make temporary directory and download latest Ghost.
cd /var/www/ghost
mkdir temp
cd temp
wget https://ghost.org/zip/ghost-latest.zip
unzip *.zip
cd ..

# Stop Ghost.
service ghost stop

# Make database backups.
for file in content/data/*.db;
do cp "$file" "${file}-backup-`date +%Y%m%d`";
done
echo "###### Database backed up. ######"

# Copy the new files over.
yes | cp temp/*.md temp/*.js temp/*.json .
rm -R core
yes | cp -R temp/core .
yes | cp -R temp/content/themes/casper content/themes
npm install --production
echo "###### NPM installed. ######"

chown -R ghost:ghost ./

# Delete temp folder.
rm -R temp

# Start Ghost again.
service ghost start
echo "###### Ghost started. ######"
