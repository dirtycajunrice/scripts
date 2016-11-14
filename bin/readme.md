# Bin Folder - Synopsis

## gitcommit.sh
Wrapper for the `git commit` command. Does a secure commit with the `-S` flag and then takes input for the `-m` message flag as the statement after the script

## logo.sh
My ASCII text logo and a good example of how to use and EOF. This is a modular part of [serverstatus.sh](#serverstatus.sh)

## moviemove.sh
*__REQUIRES__*  
[filebot](https://www.filebot.net)  
[variables.conf](#variables.conf)

This script has multiple phases

1. Checks for completed movie downloads in a specified directory and gets the folder ready for processing by deleting erronious filetypes and empty folders 
2. Runs filebot which queries TheMovieDB, checks the folder recursively, Extracts any RARs, Moving to X, Renaming by template, and stating all to a log file 
3. Cleans up all files that are extension X deleting the files first then folders recursively 
4. Checks movie folders, ensuring that all file permissions and ownership are correct. If not it fixes them 
5. Updates [PlexMediaServer](https://www.plex.tv/) in the movies section to scan for new movies with an http request 

## newvm.sh
Placed as a file in a VM which you have templated or clone often. 
* Fixes the minor initial annoyance by renaming the host, and fixing that hostname in all relevant places. 
* Fixes the IP address

## plexupdate.sh
*__REQUIRES__*  
[variables.conf](#variables.conf)



## postinstall.sh

## serverstatus.sh

## gitdelete.sh

## mkscript.sh

## movie.sh 

## organizetv.sh

## postinstallcron

## rndcreload.sh

## speedtest_cli.py
