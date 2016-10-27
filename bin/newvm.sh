#!/bin/bash

# Set hostname and ip address variable internally
oldhostname=$HOSTNAME
oldipaddress=$(ip r | awk 'NR==2{print $9}')

# Check for root
if [[ $UID -ne 0 ]]; then
	echo 'Script must be run as root'
	exit 1
fi

# Echo old hostname then ask for new hostname, suggesting a template name"
echo "Old Hostname: $oldhostname"
read -erp "New Hostname: " -i "Ubuntu1604Template" newhostname

# Echo old IP address then ask for new ip address, suggesting template ip address"
echo "Old IP address: $oldipaddress"
read -erp "New IP address: " -i "10.0.10.150" newipaddress

# Sanity check. If hostname unchanged, do nothing. Else change it.
if [[ $oldhostname == $newhostname ]]; then
	echo "Hostname unchanged. Hostname is: $oldhostname"
else
	sed -i "s/$oldhostname/$newhostname/g" /etc/hosts /etc/hostname
	hostnamectl set-hostname $newhostname
	echo "Hostname changed. Hostname is :$newhostname"
fi

# Sanity check. If hostname unchanged, do nothing. Else change it.
if [[ $oldipaddress == $newipaddress ]]; then
        echo "IP address unchanged. IP address is: $oldipaddress"
else
        sed -i 's/"$oldipaddress"/"$newipaddress"/g' /etc/network/interfaces
        sudo ifdown -a && sudo ifup -a
        echo "IP address changed. IP address is :$newipaddress"
fi

