# Bin Folder - Synopsis
A collection of scripts that i have written that make my life easier in one way or another.
## gitcommit.sh
Wrapper for the `git commit` command. Does a secure commit with the `-S` flag and then takes input for the `-m` message flag as the statement after the script

## logo.sh
My ASCII text logo and a good example of how to use and EOF. This is a modular part of [serverstatus.sh](#serverstatussh)

## moviemove
*__REQUIRES__*  
[filebot](https://www.filebot.net)  
[variables.conf](#variablesconf)

This script has multiple phases

1. Checks for completed movie downloads in a specified directory and gets the folder ready for processing by deleting erronious filetypes and empty folders
2. Runs filebot which queries TheMovieDB, checks the folder recursively, Extracts any RARs, Moving to X, Renaming by template, and stating all to a log file
3. Cleans up all files that are extension X deleting the files first then folders recursively
4. Checks movie folders, ensuring that all file permissions and ownership are correct. If not it fixes them
5. Updates [PlexMediaServer](https://www.plex.tv/) in the movies section to scan for new movies with an http request

## newvm
Placed as a file in a VM which you have templated or clone often.
* Fixes the minor initial annoyance by renaming the host, and fixing that hostname in all relevant places.
* Fixes the IP address

## plexupdate
*__REQUIRES__*  
[variables.conf](#variablesconf)

This script has multiple phases

1. Checks the [Plex](https://plex.tv) website for the current version and compares that to the version currently installed on the local system
2. Checks to see if there are any current streams on the server.
3. If either there are no streams currently or you specify `--force`, and your version is out of date, downloads and updates the installation
4. Cleans up the downloaded .deb file afterwards

## postinstall
*__REQUIRES__*  
[postinstallcron](#postinstallcron)

Ran after a fresh install.

* Removes unwanted default MOTD files
* Creates/Adds to .bash_aliases file with commonly used aliases
* Updates and upgrades
* Installs what i consider to be "core" packages
* Clones my [scripts](https://github.com/DirtyCajunRice/scripts) repo
* Moves [postinstallcron](#postinstallcron) to cron.d for my MOTD
* Links my bin folder from my repo to my home directory so that bash can add that path automatically

## serverstatus
Gives all major important system statistics:  
Date | Hostname | External/Internal IP | OS Version | Kernel | Uptime | CPU Load Averages | Current CPU Load | RAM Cached/Free | Swap In Use | Disk Space Breakdown  
The Disk Space Breakdown also gives grouped space summaries if you named your mount points numerically ascending  
e.g. /tv /tv2 /tv3 

## gitdelete
Wrapper to delete a github branch. Makes life that much easier when you are doing pull requests and merging consistantly.

## mkscript.sh
Does the major things you have to do with all scripts. Argument is the name of the script.
* Creates the file
* Makes it executable for you
* Adds shebang to line 1
* puts you into the script to start editing (Nano)
## movie.sh

## organizetv
*__REQUIRES__*  
[Sickrage](https://sickrage.github.io)

This script has multiple phases

1. Does and sqlite call to the sickbeard.db database and creates a temporary file with a list of shows and their continuing/ended status
2. Gets a total count of all shows for counter purposes
3. Checks to see if shows are properly located. If not, it moves them to their respective folders based on status
4. Load Balances shows between folders for continuing shows if one folder (HDD) gets to be within 100GB of full
5. If a show is moved, updates the sickbeard.db to reflect the new location

## postinstallcron
*__REQUIRES__*  
[logo.sh](#logosh)  
[serverstatus](#serverstatussh)

Cronjob that concatenates logo.sh and serverstatus.sh to the `/etc/motd` file every 5 minutes.

## rndcreload.sh
*__REQUIRES__*  
[Bind9](http://packages.ubuntu.com/xenial/bind9)

Reloads bind server and pulls the important information from it to make sure the dns zone updated successfully

## speedtest_cli.py
Shamelessly taken from [sivel's Repo](https://github.com/sivel/speedtest-cli)

## variables.conf
This file does not exist initially. It is simply a text file with bash variables that should not be stored directly in the script.  
e.g. usernames, passwords, tokens, etc. Examples:  
username='jdoe'  
plextoken='a&Ny8&ynONy7'


---
All scripts that use commands/packages requiring sudo privileges will check for such at the beginning.
