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

# add git repo
sudo git clone https://github.com/DirtyCajunRice/scripts.git /opt/DirtyCajunRice

(crontab -l ; echo '*/5 * * * * /home/nick/bin/10-logo > /etc/motd && /home/nick/bin/50-loadinfo >> /etc/motd && /home/nick/bin/60-cluster-status >> /etc/motd') | crontab -
