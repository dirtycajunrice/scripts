#!/bin/bash
sudo rndc reload
sleep 4
journalctl -u bind9 -n 200 | grep -e "dirtycajunrice.com" -e "10.0.10"