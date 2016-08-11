#!/bin/bash

# Before running filebot check to see if there are any filetypes that arent extension X,
# if so delete the files recursively then delete the folders recursively
if [[ $(find /dir/torrents/completed -type f ! \( -iname "*.r*" -o -iname "*.mkv" \
                                                  -o -iname "*.srt*" -o -iname "*.mp4" -o -iname "*.avi" \
                                                  -o -iname "*.m2ts" \)) ]]; then
    echo "Deleting these files/folders pre-processing:"
    find /dir/torrents/completed -type f ! \( -iname "*.r*" -o -iname "*.mkv" -o -iname "*.srt*" \
                                              -o -iname "*.mp4" -o -iname "*.avi" -o -iname "*.m2ts" \) \
                                              -print -delete
    find /movies /movies2 /dir/torrents/completed -iname "*sample*" -type f -print -delete
    find /movies /movies2 /dir/torrents/completed -mindepth 1 -type d -empty -print -delete
elif [[ $(find /movies /movies2 /dir/torrents/completed -mindepth 1 -type d -empty) ]]; then
    echo "Deleting these folders pre-processing:"
    find /movies /movies2 /dir/torrents/completed -mindepth 1 -type d -empty -print -delete
else
    echo "No files/folders to delete pre-processing"
fi

# Run filebot finding movies with TheMovieDB, recursively, Extracting, Moving to X, Renaming by template,
# and stating all to a log file.
if [[ $(filebot -r -mediainfo --db TheMovieDB /dir/torrents/completed) ]]; then
    filebot -r --output /movies2 -rename /dir/torrents/completed --db TheMovieDB -extract --action move \
            --log-file /home/nick/movielists/moviemove.log --format "{n} ({y})({vf})/{n} ({y})({vf})"
else
    echo "There are no processable movie files"
fi

# After running filebot clean up all files that are extension X deleting the files first then folders recursively
if [[ $(find /movies /movies2 /dir/torrents/completed -type f ! \( -iname "*.mkv" -o -iname "*.mp4" -o \
                                                                   -iname "*.avi" -o -iname "*.m2ts" -o \
                                                                   -iname "*.srt" \)) ]]; then
    echo "Deleting thise files/folders post-processing:"
    find /movies /movies2 /dir/torrents/completed -type f ! \( -iname "*.mkv" -o -iname "*.mp4" -o \
                                                               -iname "*.avi" -o -iname "*.m2ts" -o \
                                                               -iname "*.srt" \) -print -delete
    find /movies /movies2 /dir/torrents/completed -mindepth 1 -type d -empty -print -delete

elif [[ $(find /movies /movies2 /dir/torrents/completed -mindepth 1 -type d -empty) ]]; then
    echo "Deleting thise folders post-processing:"
    find /movies /movies2 /dir/torrents/completed -mindepth 1 -type d -empty -print -delete
else
    echo "No files/folders to delete post-processing"
fi

# Check to see if directories/files have appropriate permissions if not change to apps and 774 664 respectively
if [[ $(find /movies /movies2 -type d \( ! -group apps -o ! -perm 774 \)) ]]; then
    echo "Changing these directories to Group:apps and Permissions:774"
    find /movies /movies2 -type d \( ! -group apps -o ! -perm 774 \) -print -exec chmod 774 {} + \
                                                                     -exec chgrp apps {} +
else
    echo "All directory permissions correct"
fi

if [[ $(find /movies /movies2 -type f \( ! -group apps -o ! -perm 664 \)) ]]; then
    echo "Changing these files to Group:apps and Permissions:664"
    find /movies /movies2 -type f \( ! -group apps -o ! -perm 664 \) -print -exec chmod 664 {} + \
                                                                     -exec chgrp apps {} +
else
    echo "All file permissions correct"
fi

echo  "Updating Plex Movie Database"
curl http://10.0.10.100:32400/library/sections/1/refresh?X-Plex-Token=qxz9cdraUwK77M2pZGKK
