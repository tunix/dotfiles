# vim: set ft=just :
# Shell-adjacent one-time steps that are not plain file deployments.

# Enable ~/.dir_colors in bash (appends one line to ~/.bashrc once).
[group('shell')]
bashrc-dircolors:
    #!/bin/sh
    set -eu
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init bashrc-dircolors
    line='test -r ~/.dir_colors && eval $(dircolors ~/.dir_colors)'
    if [ -f "$HOME/.bashrc" ] && grep -qxF "$line" "$HOME/.bashrc"; then
        ui_ok "~/.bashrc already loads ~/.dir_colors"
        exit 0
    fi
    printf '\n%s\n' "$line" >>"$HOME/.bashrc"
    ui_upd "~/.bashrc now loads ~/.dir_colors"

# Rebuild bat's theme cache when the deployed bat config/themes changed.
[group('shell')]
bat-cache:
    #!/bin/sh
    set -eu
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init bat-cache
    bat=$(command -v bat || command -v batcat || true)
    if [ -z "$bat" ]; then
        ui_skip "bat not installed"
        exit 0
    fi
    state="$HOME/.cache/dotfiles/bat.sum"
    sum=$(cat "$HOME/.config/bat/config" "$HOME/.config/bat/themes/"* 2>/dev/null | cksum)
    if [ -f "$state" ] && [ "$(cat "$state")" = "$sum" ]; then
        ui_ok "theme and syntax cache up to date"
        exit 0
    fi
    ui_run "$bat" cache --build
    mkdir -p "$(dirname "$state")"
    printf '%s\n' "$sum" >"$state"
    ui_upd "theme and syntax cache rebuilt"
