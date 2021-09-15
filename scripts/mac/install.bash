#!/bin/bash
# vim:set ft=bash et sw=4:

if ask "Continue package installation?"; then
    BREW_FLAGS="-q"

    # TODO: modify PATH (via ~/.profile)

    # install brew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    brew bundle $BREW_FLAGS --file=$DOTFILES_ROOT/scripts/mac/Brewfile
else
    echo "Continuing without installating packages..."
fi
