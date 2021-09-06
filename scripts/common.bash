#!/bin/bash
# vim:set ft=bash et sw=4:

ask() {
    while true; do
        read -p "$* [y/N]: " yn

        case $yn in
            [Yy]*) return 0;;  
            *) return  1;;
        esac
    done
}

die() {
    echo "$@"

    exit 1
}

getDotFilesRoot() {
    SOURCE="${BASH_SOURCE[0]}"
    
    while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
        DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
        SOURCE="$(readlink "$SOURCE")"
        # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
        [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
    done

    DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

    echo "$DIR" | sed 's/\/scripts//'
}

delete() {
    echo "Deleting $1..."

    rm -rf "$1" &> /dev/null
}

download() {
    echo "Downloading $1..."

    if [[ ! -f "$2" ]]; then
        curl -sL $1 -o "$2"
    fi
}

clone() {
    echo "Cloning $1..."

    mkdir -p "$(dirname $2)"

    # TODO: update
    if [ ! -d "$2" ]; then
        git clone $1 "$2" &> /dev/null
    fi
}

install() {
    echo "Installing $1..."

    parent=$(dirname "$1")
    directory=$(basename "$1")

    stow -d "$parent" -t $HOME "$directory"
}

separator() {
    echo
    echo "---"
    echo
}
