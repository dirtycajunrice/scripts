# Initially copied from https://github.com/diethnis/standalones/blob/master/hastebin.sh
# Then cleaned up and modified for my use case
haste () {
    local __USAGE="Usage: haste [options] [file]

Options:
  -r, --raw      Get the raw link to the output.
  -h, --help     Print this help text.

Upload the contents of plaintext document to a hastebin.
Invocation with no arguments takes input from stdin or pipe.
haste server location can be changed with the \$HASTE_SERVER environment variable
"
    local CONTENTS OUTPUT RETURN RAW
    local HS=${HASTE_SERVER:-hastebin.com}
    while [[ $# -gt 0 ]]; do
    local KEY="$1"
        case $KEY in
            -h|--help)
              echo -n "$__USAGE"
              return 1
              ;;
            -r|--raw)
              RAW="/raw/"
              shift
              shift
              ;;
            *)
              POSITIONAL+=("$1")
              shift
              ;;
        esac
    done

    set -- "${POSITIONAL[@]}" # restore positional parameters
    if [[ -p /dev/stdin ]]
    then
        CONTENTS=$(cat)
    elif (( $# != 1 ))
    then
        echo -n "$__USAGE"
        return 1
    elif [[ -e $1 && ! -f $1 ]]
    then
        echo "Error: Not a regular file."
        return 1
    elif [[ ! -e $1 ]]
    then
        echo "Error: No such file."
        return 1
    elif (( $(stat -c %s "$1") > (512*1024**1) ))
    then
        echo "Error: File must be smaller than 512 KiB."
        return 1
    fi
    if [[ -z "$CONTENTS" ]]
    then
        CONTENTS=$(cat "$1")
    fi
    OUTPUT=$(curl -sd "$CONTENTS" "https://${HS}/documents")
    if (( $? == 0 )) && [[ $OUTPUT =~ \"key\" ]]
    then
        RETURN=$(jq -r .key <<< "$OUTPUT")
        if [[ -n $RETURN ]]
        then
            echo "https://${HS}${RAW:-/}${RETURN}"
            return 0
        fi
    fi
    echo "Upload failed."
    return 1
}