#!/bin/bash
# vim:set ft=bash et sw=4:

if [[ "$XDG_SESSION_TYPE" == "x11" ]]; then

    if [[ "$ARCH" == "amd64" ]]; then

        curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg

        echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list

        sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/

        curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol

        sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22

        curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg

    fi

fi