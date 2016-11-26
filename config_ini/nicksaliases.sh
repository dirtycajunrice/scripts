#!/bin/bash
# Pullable alias for working on remote systems. bash https://dirtycajunrice.com/alias
alias whatami='if [[ -e /etc/redhat-release ]]; then cat /etc/redhat-release; else lsb_release -a; fi'
