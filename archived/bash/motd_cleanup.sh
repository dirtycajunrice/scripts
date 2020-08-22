#!/bin/bash
# Remove the canonical news garbage ubuntu installs to MOTD by default
sed -i 's/ENABLED\=1/ENABLED=0/' /etc/default/motd-news

# Remove the documentation links cluttering the top of the MOTD by default
sed -i 's/^\([^#].*\)/# \1/g' /etc/update-motd.d/10-help-text /etc/update-motd.d/80-livepatch
