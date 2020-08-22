#!/bin/bash

if [[ -z $1 ]]; then
    echo "You need to name a script"
    exit
fi

loc=~/bin/"$1"

if [[ -e $loc ]]; then
    echo "$loc already exits"
    exit
fi

touch "$loc"
chmod u+x "$loc"
echo '#!/bin/bash' > "$loc"
nano "$loc"
