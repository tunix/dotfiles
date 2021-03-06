#!/bin/bash

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

clone() {
    echo "Cloning $1..."

    mkdir -p "$(dirname $2)"

    if [ ! -d "$2" ]; then
        git clone $1 $2 &> /dev/null
    fi
}

install() {
    echo "Installing $1..."

    mkdir -p "$(dirname $2)"

    ln -sf $1 $2
}

seperator() {
    echo
    echo "---"
    echo
}
