#!/bin/bash
# vim:set ft=bash et sw=4:

if [[ "$XDG_SESSION_TYPE" == "x11" ]]; then

    if [[ "$ARCH" == "amd64" ]]; then

        sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list

    fi

fi
