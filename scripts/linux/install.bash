#!/bin/bash
# vim:set ft=bash et sw=4:

DISTRIBUTION=$(lsb_release -is)

if ask "Continue package installation?"; then
    case "$DISTRIBUTION" in

        Pop|Ubuntu)
            source $DOTFILES_ROOT/scripts/linux/ubuntu/install.bash
            ;;

        Raspbian)
            source $DOTFILES_ROOT/scripts/linux/raspbian/install.bash
            ;;

        *) die "Unknown distribution. Aborting."

    esac

    clone https://github.com/arcticicestudio/nord-dircolors.git /tmp/nord-dircolors \
        && cp /tmp/nord-dircolors/src/dir_colors $HOME/.dir_colors

    source $DOTFILES_ROOT/scripts/linux/fonts.bash
    source $DOTFILES_ROOT/scripts/linux/theme.bash
else
    echo "Continuing without installating packages..."
fi