#!/bin/bash
if [[ -z $1 ]]; then
    echo "You need to put a branch after the command"
    echo "e.g. gitdelete somebranch"
else
    git push origin --delete "$1"
    git push origin :"$1"
fi