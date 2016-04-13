#!/bin/bash

# Variables
badfiles="\
/etc/update-motd.d/00-header
/etc/update-motd.d/10-help-text\
"

# Script to add to every server i work on or mangage Check for root
if [[ $UID -ne 0 ]]; then
	echo 'Script must be run as root'
	exit 0
fi

# Remove unwanted and soon to be replaced files
for file in $badfiles; do
    if [[ -e $file ]]; then
        rm $file
    fi
done

# Download Wanted scripts/files
wget -q dirtycajunrice.com/bin/10-logo dirtycajunrice.com/bin/50-loadinfo

# Move scripts/files to their final destination and change their respective owners/permissions
chown root:root 10-logo && chmod 755 10-logo && mv 10-logo /etc/update-motd.d/
chown root:root 50-loadinfo && chmod 755 50-loadinfo && mv 50-loadinfo /etc/update-motd.d/50-loadinfo

# Append hosts to hostfile
#echo -e "
# Added Hosts by DirtyCajunRice on $(date +"%D %r %Z")
#$(nslookup dirtycajunrice.com | grep Address | awk 'END { printf $2 }') cajunserver
#" | tee -a /etc/hosts

# Create .bash_aliases or append to it
if [[ ! -e ~/.bash_aliases ]]; then
    touch ~/.bash_aliases && chmod 664 ~/.bash_aliases && chown $(logname) ~/.bash_aliases
fi
#echo -e "
# Added aliases by DirtyCajunRice on $(date +"%D %r %Z")
#alias pastebin='nc termbin.com 9999'
#" >> ~/.bash_aliases

# Update, Upgrade, and Distribution Upgrade
apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y

# Install always used programs (including LAMPP)
apt-get install git unrar-free apache2 samba php5 python3.5 python3.4 python expect -y
