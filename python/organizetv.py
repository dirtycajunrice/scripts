#!/usr/bin/env python3

import os
import sys
import requests
import shutil
import progressbar
from operator import itemgetter

URL = 'http://localhost:8989/'
API_KEY = 'f8e02e5698024512a270d351fdc89c39'

ENDED_SHOW_DRIVES = ('/tv', '/tv1')
CONTINUING_SHOW_DRIVES = ('/tv2', '/tv3', '/tv4')
LOAD_BALANCED_STATUSES = ('continuing', 'ended')  # Options: continuing, ended, or list of both
BUFFER = 100000000000  # 100GB

# Check if ran by root
if not os.geteuid() == 0:
    sys.exit('Script must be run as root')

# REST API call to sonarr for show dict
API = 'api/series'
HEADERS = {'X-Api-Key': API_KEY}
R = requests.get(URL + API, headers=HEADERS)
SHOWS = {d['title']: d for d in R.json()}

# Create dict for show drives
show_drive = {'ended': {}, 'continuing': {}}
for drives in ENDED_SHOW_DRIVES:
    show_drive['ended'][drives] = {}
for drives in CONTINUING_SHOW_DRIVES:
    show_drive['continuing'][drives] = {}


def drive_stats():  # Create drives in dict with sizes all in bytes
    for tv_status in show_drive.keys():
        for root_drive in show_drive[tv_status]:
            total, used, free = shutil.disk_usage(root_drive)
            show_drive[tv_status][root_drive]['size'] = total
            show_drive[tv_status][root_drive]['free'] = free
            if show_drive[tv_status][root_drive]['free'] <= BUFFER:
                show_drive[tv_status][root_drive]['usable'] = 'no'
            else:
                show_drive[tv_status][root_drive]['usable'] = 'yes'


def show_stats(show_name):  # Update show stats
    # Sanitize names removing trailing periods and any colons
    s_name = show_name.rstrip('.').replace(':', '')
    s_status = SHOWS[show]['status']
    s_path = SHOWS[show]['path']
    s_size = SHOWS[show]['sizeOnDisk']
    s_drive_on_disk = where_am_i(show_name=s_name)
    return s_name, s_status, s_path, s_size, s_drive_on_disk


def folder_size(path):
    total = 0
    for entry in os.scandir(path):
        if entry.is_file():
            total += entry.stat().st_size
        elif entry.is_dir():
            total += folder_size(entry.path)
    return total


def choose_drive(tv_status, show_size):
    for root_drive in show_drive[tv_status]:
        if show_drive[tv_status][root_drive]['free'] - show_size > BUFFER:
            return root_drive
    return None


def where_am_i(show_name):
    for tv_status in show_drive.keys():
        for root_drive in show_drive[tv_status]:
            for root, dirs, files in os.walk(root_drive):
                if show_name in dirs:
                    return root
                del dirs[:]


def drives_full(tv_status):
    exit('Error: all ' + tv_status + ' drives have less than ' + str(BUFFER / 1000000) + 'MB remaining')


def mover(tv_status, show_size, show_name, old_drive, reason):
    new_drive = choose_drive(tv_status, show_size)
    if new_drive is not None:
        if reason == 'ended' or reason == 'continuing':
            print('Moving ' + show_name + ' from ' + old_drive + ' to ' + new_drive +
                  ' because its current status is ' + status)
        elif reason == 'balance':
            print('Moving ' + show_name + ' from ' + old_drive + ' to ' + new_drive +
                  ' because ' + old_drive + ' is too full')

        old_location = os.path.join(old_drive, show_name)
        new_location = os.path.join(new_drive, show_name)
        all_files = []
        for root, dirs, files in os.walk(old_location):
            for file in files:
                all_files.append(file)
        with progressbar.ProgressBar(max_value=len(all_files)) as bar:
            count = 0
            for root, dirs, files in os.walk(old_location):
                if not os.path.exists(os.path.join(new_drive, show_name)):
                    os.makedirs(os.path.join(new_drive, show_name))
                for dir in dirs:
                    dir_path = os.path.join(new_drive, dir)
                    if not os.path.exists(dir_path):
                        os.makedirs(dir_path)
                for file in files:
                    folder_name = os.path.basename(root)
                    shutil.move(os.path.join(old_location, folder_name, file), os.path.join(new_location, folder_name))
                    count += 1
                    bar.update(count)

        if folder_size(old_location) == folder_size(new_location):
                shutil.rmtree(old_location)
        else:
            print('There was something wrong with the move. Please check for consistency')

        print('Updating Sonarr to reflect the move...')
        status_code = updater(show_name=show_name, show_location=new_drive)

        if status_code == 202:
            print('Success!')
        else:
            print('Sonarr update failed with Status Code: ' + status_code)

    else:
        drives_full(status)


def updater(show_name, show_location):
    root, paths = os.path.split(SHOWS[show_name]['path'])
    root = show_location
    SHOWS[show_name]['path'] = os.path.join(root, paths)
    put = requests.put(URL + API, headers=HEADERS, json=SHOWS[show_name])
    return put.status_code


# Move all shows to appropriate drives based on status
for show in SHOWS.keys():
    drive_stats()
    # Sanitize names removing trailing periods and any colons
    name, status, p, size, drive_on_disk = show_stats(show_name=show)

    if drive_on_disk in show_drive['continuing'] and status == 'ended':
        mover(tv_status=status, show_size=size, show_name=name, old_drive=drive_on_disk, reason='ended')
    elif drive_on_disk in show_drive['ended'] and status == 'continuing':
        mover(tv_status=status, show_size=size, show_name=name,old_drive=drive_on_disk, reason='continuing')
# move shows on continuing drives with less than buffer
for show_status in LOAD_BALANCED_STATUSES:
    for hard_drive in show_drive[show_status]:
        while show_drive[show_status][hard_drive]['free'] <= BUFFER:
            drive_stats()
            size_compare = []
            for names in SHOWS.keys():
                name, status, path, size, drive_on_disk = show_stats(show_name=names)
                pre, base = os.path.split(path)
                if pre == hard_drive:
                    size_compare.append([name, size])
            biggest_show = max(size_compare, key=itemgetter(1))
            mover(tv_status=status, show_size=biggest_show[1], show_name=biggest_show[0], old_drive=drive_on_disk, reason='balance')

# make sure all files/folders have correct permissions and ownership
for show_status in show_drive.keys():
    for hard_drive in show_drive[show_status]:
        for base_dir, directory, file in os.walk(hard_drive):
            for d in directory:
                full_path = os.path.join(base_dir, d)
                os.chmod(full_path, 0o774)
                shutil.chown(full_path, group='apps')
            for f in file:
                full_path = os.path.join(base_dir, f)
                os.chmod(full_path, 0o664)
                shutil.chown(full_path, group='apps')

