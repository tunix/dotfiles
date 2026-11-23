# vim: set ft=just :
# Shell-adjacent one-time steps that are not plain file deployments.

# Enable ~/.dir_colors in bash (appends one line to ~/.bashrc once).
[group('shell')]
bashrc-dircolors:
    #!/bin/sh
    set -eu
    line='test -r ~/.dir_colors && eval $(dircolors ~/.dir_colors)'
    if [ -f "$HOME/.bashrc" ] && grep -qxF "$line" "$HOME/.bashrc"; then
        echo "~/.bashrc already loads ~/.dir_colors; nothing to do."
        exit 0
    fi
    printf '\n%s\n' "$line" >> "$HOME/.bashrc"
    echo "~/.bashrc now loads ~/.dir_colors"

# Rebuild bat's theme cache when the deployed bat config/themes changed.
[group('shell')]
bat-cache:
    #!/bin/sh
    set -eu
    bat=$(command -v bat || command -v batcat || true)
    [ -n "$bat" ] || { echo "bat not installed; nothing to do."; exit 0; }
    state="$HOME/.cache/dotfiles/bat.sum"
    sum=$(cat "$HOME/.config/bat/config" "$HOME/.config/bat/themes/"* 2>/dev/null | cksum)
    if [ -f "$state" ] && [ "$(cat "$state")" = "$sum" ]; then
        echo "bat cache up to date; nothing to do."
        exit 0
    fi
    "$bat" cache --build
    mkdir -p "$(dirname "$state")"
    printf '%s\n' "$sum" > "$state"
