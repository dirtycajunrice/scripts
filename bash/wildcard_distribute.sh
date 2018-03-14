#!/bin/bash

domain='example.com'

server_distro_list=('server-a' 'server-b' '192.168.1.100')

# Check if ran by root
if [[ $UID -ne 0 ]]; then
    echo 'Script must be run as root'
    exit
fi

echo "Checking to see if certbot-auto is in /usr/local/bin..."
if [ ! -f /usr/local/bin/certbot-auto ]; then
    echo "Downloading certbot-auto to /usr/local/bin"
    wget -qO /usr/local/bin/certbot-auto https://dl.eff.org/certbot-auto
else
    echo "certbot-auto already downloaded"
fi

echo "Checking file permissions of certbot-auto..."
if [ "$(stat -c %A /usr/local/bin/certbot-auto | sed -e 's/\(.\)../\1/g' | cut -c 2-)" != "xxx" ]; then
    chmod a+x /usr/local/bin/certbot-auto
    echo "fixed certbot-auto permissions (a+x)"
else
    echo "certbot-auto permissions correct"
fi

echo "You will have to add 2 TXT records to your DNS host/provider"
echo "Click continue after the first TXT prompt to get both at once"

# Comment this out once script has worked once to create crontab 
while true; do
    read -rp "Are you ready to obtain your cert? (y/n)" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

/usr/local/bin/certbot-auto certonly -d \*.$domain -d $domain --server https://acme-v02.api.letsencrypt.org/directory --manual --preferred-challenge dns

# Comment this out once script has worked once to create crontab 
while true; do
    read -rp "Distribute to server distro list? (y/n)" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

copysshkey=false

# Comment this out once script has worked once to create crontab 
while true; do
    read -rp "Do you need to copy ssh-keys? (y/n)" yn
    case $yn in
        [Yy]* ) copysshkey=true; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

if $copysshkey; then
    if [ ! -f /root/.ssh/id_rsa.pub ]; then
        echo "No root ssh key. Generating one..."
        ssh-keygen -t rsa -b 2048 -N "" -f "/root/.ssh/id_rsa" -q
    fi
    echo "Copying SSH Keys. This copies root's ssh key as it letsencrypt uses root permissions in the live/ folder"
    for server in "${server_distro_list[@]}"; do
        ssh-copy-id "$server"
    done
fi

for server in "${server_distro_list[@]}"; do
     echo "Copying wildcard cert to $server"
    scp -rp /etc/letsencrypt/live/"$domain" "$server":/etc/letsencrypt/live/
done

echo "Done!"
