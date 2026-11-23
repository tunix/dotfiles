# vim: set ft=just :
# GNOME-integration services that need more than a file copy (the units and
# helpers themselves are deployed by `just apply` from linux/gnome/home/).
# Everything here reads or writes org.gnome.* gsettings.

# Keep CLI themes (zellij/k9s/bat/nvim) in sync with GNOME color-scheme
# (penguix-theme-sync user unit). The unit calls
# ~/.local/bin/toggle-color-preferences.sh from the common layer.
[linux]
[group('desktop')]
theme-sync: (user-unit "penguix-theme-sync.service")
    #!/usr/bin/env bash
    if ! [ -x "$HOME/.local/bin/toggle-color-preferences.sh" ]; then
        echo "WARN: ~/.local/bin/toggle-color-preferences.sh missing (run 'just apply');" >&2
        echo "      theme-sync only logs until the script appears." >&2
    fi

# Re-evaluate color-scheme every minute from local sunrise/sunset
# (penguix-sun-scheduler user timer). Location comes from
# night-light-last-coordinates (gsd writes it when Night Light follows the
# system location); fallback: fixed 09:00 light / 18:00 dark.
[linux]
[group('desktop')]
sun-scheduler: (user-unit "penguix-sun-scheduler.timer")

# Install a Bibata cursor theme variant into ~/.local/share/icons (userspace)
# and select it. Fast-exits when the variant is already installed.
# Variants: Modern/Original x Ice (white)/Classic (black)/Amber (yellow),
# optional -Right (right-pointing). Release pinned: ful1e5/Bibata_Cursor v2.0.7.
[linux]
[group('desktop')]
bibata variant='Bibata-Modern-Ice':
    #!/usr/bin/env bash
    set -euo pipefail
    dest="$HOME/.local/share/icons/{{ variant }}"
    if [ -f "$dest/index.theme" ]; then
        echo "Bibata '{{ variant }}' already installed; nothing to do."
    else
        ver="v2.0.7"
        url="https://github.com/ful1e5/Bibata_Cursor/releases/download/${ver}/{{ variant }}.tar.xz"
        tmp="$(mktemp -d)"
        trap 'rm -rf "$tmp"' EXIT
        echo "Downloading Bibata {{ variant }} (${ver})..."
        curl -fsSL -o "$tmp/theme.tar.xz" "$url"
        mkdir -p "$HOME/.local/share/icons"
        tar -xf "$tmp/theme.tar.xz" -C "$HOME/.local/share/icons/"
        [ -f "$dest/index.theme" ] || {
            echo "ERROR: unexpected tarball layout (no $dest/index.theme)" >&2
            exit 1
        }
        echo "Installed -> $dest"
    fi
    current="$(gsettings get org.gnome.desktop.interface cursor-theme 2>/dev/null || true)"
    if [ "$current" = "'{{ variant }}'" ]; then
        echo "cursor-theme already {{ variant }}; nothing to do."
    else
        gsettings set org.gnome.desktop.interface cursor-theme '{{ variant }}'
        echo "cursor-theme -> {{ variant }} (log out/in for every app to pick it up)"
    fi
