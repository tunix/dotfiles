#!/bin/bash

source "$(dirname $0)"/common.sh

DOTFILES_ROOT="$(getDotFilesRoot)"

if [ ! -d /tmp/nord-gnome-terminal ]; then
    git clone https://github.com/arcticicestudio/nord-gnome-terminal.git /tmp/nord-gnome-terminal
fi

pushd /tmp/nord-gnome-terminal/src \
    && ./nord.sh \
    popd
