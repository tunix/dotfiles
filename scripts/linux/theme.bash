#!/bin/bash
# vim:set ft=bash et sw=4:

if [ ! -d /tmp/nord-gnome-terminal ]; then
    clone https://github.com/arcticicestudio/nord-gnome-terminal.git /tmp/nord-gnome-terminal
fi

pushd /tmp/nord-gnome-terminal/src \
    && ./nord.sh \
    popd
