#!/bin/bash

echo
echo "Updating shows.list"
echo

# sqlite3 database query to pull list of shows from sickbeard.db
sqlite3 /opt/SickRage/sickbeard.db "SELECT show_name, status FROM tv_shows" > ~/shows.list

# Moving shows to /tv (Ended) and /tv2 (Continuing)

while read -r list; do
    name="$(echo $list | sed -e 's/|.*//' -e 's/\.$//' -e 's/://')"
    status="$(echo $list | sed 's/.*|//')"
    if [ "$status" = "Continuing" ]; then
        if [[ "$name" = $(find /tv -maxdepth 1 -type d -name "$name" -exec basename {} \;) ]]; then
            mv -nv /tv/"$name"/ /tv2
        else
            echo "Wtf? I cant find $name. Check spelling maybe?"
        fi
    elif [ "$status" = "Ended" ]; then
        if [[ "$name" = $(find /tv2 -maxdepth 1 -type d -name "$name" -exec basename {} \;) ]]; then
            mv -nv /tv2/"$name"/ /tv
        else
            echo "Wtf? I cant find $name. Check spelling maybe?"
        fi
    fi
done < ~/shows.list
