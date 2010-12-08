#!/bin/bash

function seq () {
    (( $# >= 1 )) || return 0
    
    local format='%g'
    local separator=$'\n'
    local equal_width=false

    local flag
    OPTIND=1
    while [[ ${!OPTIND} =~ ^-[^[:digit:]] ]]; do
        getopts "f:s:w" flag || break
        case "$flag" in
            "f")
                format="$OPTARG"
            ;;
            "s")
                separator="$OPTARG"
            ;;
            "w")
                equal_width=true
            ;;
        esac
    done
    shift $((OPTIND-1))
    OPTIND=1

    local first=1
    local increment=1
    local last
    case $# in
        3)
            last=$3
            increment=$2
            first=$1
        ;;
        2)
            last=$2
            first=$1
        ;;
        1)
            last=$1
        ;;
        *)
            echo "Usage: seq [first [increment]] last" 1>&2
            return 1
        ;;
    esac
    
    if $equal_width; then
        [[ $format =~ %([[:digit:]]*)(.) ]] || { echo "invalid format string: \`$format'" 1>&2; return 1; }
        local first_width=$(printf "%${BASH_REMATCH[2]}" $first)
        local last_width=$(printf "%${BASH_REMATCH[2]}" $last)
        local max_width=$(( ${#first_width} > ${#last_width} ? ${#first_width} : ${#last_width} ))
        format=${format/\%${BASH_REMATCH[1]}?/%0${max_width}${BASH_REMATCH[2]}}
    fi

    local compare
    if (( first <= last )); then
        compare='<='
    else
        compare='>='
    fi
    (( increment $compare 0 )) && return 0

    local i
    for (( i=$first; i $compare last; i=i+increment )); do
        [ "$i" -ne "$first" ] && echo -n "$separator"
        printf "$format" $i
    done
    echo ''
}

seq "$@"
