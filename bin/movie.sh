#!/bin/bash
 
# Exported Variablees
export d=~/movielists
export halp="You must have 1 or more arguments. Type -h or --help for help with arguments"
export spacer="---------------------------------------------------"
export arg2="$2"
export quality='360p 480p 720p 1080p 2160p'
 
# shellcheck source=/dev/null
source ~/bin/mklog  # Calls mklog script which creates a log that prepends the date and time
                     # and [ERROR] if errors exist.
 
# Functions
 
moviestats() {  # Sorts all movies into seperate quality lists and prints results to the terminal.
echo $spacer
echo "Creating $d..."
if
    [ -d "$d" ]
then
    echo "$d already existed"
else
    mkdir $d
    echo "Created $d"
fi
echo $spacer
echo "Updating lists..."
if
    [ ! -w $d/movies.list ]
then
    echo "Created movies.list"
    ls /movies > $d/movies.list
else
    ls /movies > $d/movies.list
    echo "Updated maser movies list"
    num=$(wc -l < "$d"/movies.list)
    echo "You have $num movies"
fi
    grep -vE '(2160|1080|720|480|360)p' $d/movies.list > $d/oddquality.list
 
if
    ! grep -qvE '(2160|1080|720|480|360)p' $d/movies.list
then
    rm $d/oddquality.list
    echo "You have no odd quality movies! Fuck Yeah!"
else
    echo "Updated the Odd Quality List"
    num=$(wc -l < $d/oddquality.list)
    echo "You have $num Odd Quality movies left to upgrade"
fi
for list2 in $quality
    do
        grep "$list2" $d/movies.list > "$d"/"$list2".list
        if
            ! grep -q "$list2" "$d"/"$list2".list
        then
            rm "$d"/"$list2".list
            echo "You have no $list2 movies! Fuck Yeah!"
        elif
            [ "$list2" = "720p" ]
        then
            listupdate
            echo "You have settled with $num movies at $list2 quality"
        elif
            [ "$list2" = "1080p" ]
        then
            listupdate
            echo "You have upgraded $num movies to $list2 quality"
        elif
            [ "$list2" = "2160p" ]
        then
            listupdate
            echo "$num movies have acended to $list2 quality"
        else
            listupdate
            echo "You have $num $list2 movies left to upgrade"
        fi
    done
echo $spacer
}
listloop() {
    echo $spacer
    cat "$d/$arg2.list"
    echo $spacer
}
listupdate() {
echo "Updated the $list2 list"
num=$(wc -l < "$d"/"$list2".list)
}
dupeloop() {  # Prints all movies in list and their dupe. No Highlighting.
    while
        read -r movie
    do
        movie2=${movie%(*}
        grep -Fv "$movie" $d/movies.list | grep -Fq "$movie2" && printf "%s is duplicate\n" "$movie"
    done < "$d"/"$arg2".list
}
dupecheck() {
    if
        [ -z "$(dupeloop)" ]
    then
        echo "You have no duplicates!"
    fi
}
moviestats > /dev/null
if
    [[ $# == 0 ]]
then
    echo "$halp"
    exit 1
fi
if
    [[ $# == 1 ]]
then
    if
        [[ $1 == *-* ]]
    then
        if
            [[ $1 == *-h* ]]
        then
            cat ~/bin/moviesource/movie.man
            exit
        fi
    elif
        [[ $1 == "stats" ]]
    then
        moviestats
        exit
    elif
        [[ $1 == "list" ]]
    then
            echo -n 'Quality? (2160|1080|720|480|360)p: '
            read -r args
            echo "$args"
            echo $spacer
            arg2=$args
            listloop
            exit
    elif
        [[ $1 == "dups" ]]
    then
        echo $spacer
        echo -n 'Quality? (2160|1080|720|480|360)p: '
        read -r args
        echo "$args"
        echo $spacer
        dupeloop
        dupecheck
        exit
    fi
fi
if
    [[ $# == 2 ]]
then
    if
        [[ "$1" == "list" ]]
    then
        if
            [ "$2" = "all" ]
        then
            arg2=movies
            echo $spacer
            cat "$d/$arg2.list"
            echo $spacer
            exit
        else
            echo
            listloop
            exit
        fi
    elif
        [ "$1" = "dups" ]
    then
        if
            [ "$2" = "all" ]
        then
            arg2=movies
            dupeloop
            dupecheck
        elif
            [ "$2" = "test" ]
        then
            dupeloop
            dupecheck
        else
            dupeloop
            dupecheck
        fi
    fi
exit 0
fi
echo "End of script"
echo $spacer
exit 0
