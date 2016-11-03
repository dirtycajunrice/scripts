#!/bin/bash

# Check if ran by root
if [[ $UID -ne 0 ]]; then
    echo 'Script must be run as root'
    exit 1
fi

# Reload bind9
rndc reload

# Print status to stdout for anything from dirtycajunrice.com or 10.0.10 and 3 lines back
grep -e "dirtycajunrice.com" -e "10.0.10" /var/log/bind/bind.log