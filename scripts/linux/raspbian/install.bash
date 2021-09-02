#!/bin/bash
# vim:set ft=bash et sw=4:

APT_FLAGS="-qy"

CORE_PACKAGES=(
    language-pack-tr
    tmux
    neofetch
    neovim
    exa
    jq
    silversearcher-ag
    uptimed
    ansible
    bat
    stow
    fish
    docker-ce
    docker-ce-cli
    containerd.io
    tailscale
)

source $DOTFILES_ROOT/scripts/linux/raspbian/ppa.bash

sudo apt update \
    && sudo apt install $APT_FLAGS ${PACKAGES[@]}
