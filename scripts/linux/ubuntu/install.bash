#!/bin/bash
# vim:set ft=bash et sw=4:

APT_FLAGS="-qy"

CORE_PACKAGES=(
    language-pack-tr
    snapd
    tmux
    neofetch
    neovim
    exa
    jq
    silversearcher-ag
    uptimed
    ansible
    openjdk-8-jdk-headless
    bat
    stow
    fish
    docker-ce
    docker-ce-cli
    containerd.io
    tailscale
    flatpak
    libsecret-1-dev
)

# TODO: pipewire
# TODO: kvm/virt-manager

GUI_PACKAGES=(
    caffeine
    1password
)

MANUAL_PACKAGES=(
    https://www.thefanclub.co.za/sites/default/files/public/overgrive/overgrive_3.3.10_all.deb
)

if [[ "$XDG_SESSION_TYPE" == "x11" ]]; then
    CORE_PACKAGES+=(${GUI_PACKAGES[@]})
fi

source $DOTFILES_ROOT/scripts/linux/ubuntu/ppa.bash

sudo apt update \
    && sudo apt install $APT_FLAGS ${CORE_PACKAGES[@]}

for package in ${MANUAL_PACKAGES[@]}; do

    # TODO: check if already installed

    filename=$(basename $package)

    curl -sL $package /tmp/$filename

    sudo apt install $APT_FLAGS /tmp/$filename

done

source $DOTFILES_ROOT/scripts/linux/ubuntu/snap.bash
source $DOTFILES_ROOT/scripts/linux/ubuntu/flatpak.bash
source $DOTFILES_ROOT/scripts/linux/ubuntu/git.bash
