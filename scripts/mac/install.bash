#!/bin/bash
# vim:set ft=bash et sw=4:

BREW_FLAGS="-q"

CORE_PACKAGES=(
    fish
    neovim
    the_silver_searcher
    tmux
    wget
)

echo "mac"

# TODO: modify PATH (via ~/.profile)

# install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install $BREW_FLAGS ${CORE_PACKAGES[@]}

exit 0