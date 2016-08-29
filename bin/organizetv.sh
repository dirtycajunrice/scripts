#!/bin/bash

# sqlite3 database query to pull list of shows from sickbeard.db
sqlite3 /opt/SickRage/sickbeard.db "SELECT show_name, status FROM tv_shows" | sort > /tmp/shows.list

# Total count of shows in DB
totalcount=$(wc -l < /tmp/shows.list)
# Counter for shows that are properly placed
count=0

# Moving shows to /tv (Ended) and /tv2 (Continuing)
while read -r list; do
    name="$(echo "$list" | sed -e 's/|.*//' -e 's/\.$//' -e 's/://')"
    status="$(echo "$list" | sed 's/.*|//')"
    fullpath=$(find /tv* -maxdepth 1 -type d -name "$name")
    if [ "$status" = "Continuing" ]; then
        basename=$(find /tv -maxdepth 1 -type d -name "$name" -exec basename {} \;)
        if [[ "$name" = "$basename" ]]; then
            mv -nv "$fullpath" /tv2
        else
            ((count++))
        fi
    elif [ "$status" = "Ended" ]; then
        basename=$(find /tv[2-3] -maxdepth 1 -type d -name "$name" -exec basename {} \;)
        if [[ "$name" = "$basename" ]]; then
            mv -nv "$fullpath" /tv
        else
            ((count++))
        fi
    fi
done < /tmp/shows.list

# If all shows were already properly placed, state it
if ((count = totalcount)); then
    echo "All TV shows are properly placed"
fi

# Variables for Continuing TV Show Load Balancing

# Checks disk space of /tv2 in MB, Prints column 4 (the space free), and removes the MB leaving # as $chksize
chksize=$(df -BMB /tv2 | awk 'NR==2{print $4}' | sed 's/MB//')
# Checks the directories inside of /tv2, Sorts by # in reverse (to put largest # on top), Takes only the largest
# folder and then removes everything up to the last / leaving just the folder name as $largest
largest=$(du /tv2/* -sB 1G | sort -nr | head -n1 | sed 's,^.*/,,')

# If the disk space of /tv2 ($chksize) has less than 100,000MB (100GB or .1 TB), then move the largest TV Show
# ($largest) to /tv3 so that /tv2 can safely grow
if (( "$chksize" <= "100000" )); then
    mv /tv2/"$largest" /tv3/"$largest"
else
    echo "You have $(((chksize - 100000) / 1000))GB left until load-balancing occurs"
fi
