# vim: set ft=just :
# Desktop services and fixes that need more than a file copy (the files
# themselves are deployed by `just apply` from gnome/home/).

# Keep CLI themes (zellij/k9s/bat/nvim) in sync with GNOME color-scheme by
# enabling the penguix-theme-sync systemd user unit. The unit calls
# ~/.local/bin/toggle-color-preferences.sh (common layer).
# Fast-exits when the unit is already enabled.
[linux]
[group('desktop')]
theme-sync:
    #!/usr/bin/env bash
    set -euo pipefail
    if ! [ -x "$HOME/.local/bin/toggle-color-preferences.sh" ]; then
        echo "WARN: ~/.local/bin/toggle-color-preferences.sh missing (run 'just apply');" >&2
        echo "      theme-sync will start but only log until the script appears." >&2
    fi
    state="$(systemctl --user is-enabled penguix-theme-sync.service 2>/dev/null || true)"
    if [ "$state" = "enabled" ]; then
        echo "penguix-theme-sync already enabled; nothing to do."
        exit 0
    fi
    if ! systemctl --user daemon-reload 2>/dev/null; then
        echo "WARN: no user systemd session available; run 'just theme-sync' from a desktop session later." >&2
        exit 0
    fi
    systemctl --user enable --now penguix-theme-sync.service
    echo "penguix-theme-sync enabled (CLI themes now follow GNOME color-scheme)."

# Re-evaluate color-scheme every minute from local sunrise/sunset. Location
# comes from night-light-last-coordinates (gsd writes it when Night Light
# follows the system location); fallback: fixed 09:00 light / 18:00 dark.
# Fast-exits when the timer is already enabled.
[linux]
[group('desktop')]
sun-scheduler:
    #!/usr/bin/env bash
    set -euo pipefail
    state="$(systemctl --user is-enabled penguix-sun-scheduler.timer 2>/dev/null || true)"
    if [ "$state" = "enabled" ]; then
        echo "penguix-sun-scheduler already enabled; nothing to do."
        exit 0
    fi
    if ! systemctl --user daemon-reload 2>/dev/null; then
        echo "WARN: no user systemd session available; run 'just sun-scheduler' from a desktop session later." >&2
        exit 0
    fi
    systemctl --user enable --now penguix-sun-scheduler.timer
    echo "penguix-sun-scheduler enabled (color-scheme follows local sunrise/sunset)."

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

# Enable 1Password desktop integration for the Brave flatpak. Requires the
# 1Password GUI (gnome/brew/apps.Brewfile). The talk-name override also
# ships as a file (gnome/home/.local/share/flatpak/overrides/com.brave.Browser)
# deployed by `just apply`; this recipe re-asserts it via the flatpak CLI and
# installs the native messaging host, which depends on the 1Password install.
[linux]
[group('desktop')]
brave-1password-fix:
    #!/usr/bin/env bash
    set -euo pipefail
    SRC="$HOME/.config/BraveSoftware/Brave-Browser/NativeMessagingHosts"
    DEST="$HOME/.var/app/com.brave.Browser/config/BraveSoftware/Brave-Browser/NativeMessagingHosts"
    OVERRIDE="$HOME/.local/share/flatpak/overrides/com.brave.Browser"
    if [ ! -f "${SRC}/1PasswordWrapper.sh" ] || [ ! -f "${SRC}/com.1password.1password.json" ]; then
        echo "1Password native messaging files not found in ${SRC}." >&2
        echo "Install the GUI first: just brew-sync" >&2
        exit 1
    fi
    if [ -f "${DEST}/1PasswordWrapper.sh" ] && [ -f "${DEST}/com.1password.1password.json" ] \
        && grep -q 'talk-name=org.freedesktop.Flatpak' "$OVERRIDE" 2>/dev/null; then
        echo "1Password integration for the Brave flatpak already in place; nothing to do."
        exit 0
    fi
    flatpak override --user --talk-name=org.freedesktop.Flatpak com.brave.Browser
    mkdir -p "${DEST}"
    install -m 755 "${SRC}/1PasswordWrapper.sh" "${DEST}/1PasswordWrapper.sh"
    sed -E "s|\"path\": \".*\"|\"path\": \"${DEST}/1PasswordWrapper.sh\"|" \
        "${SRC}/com.1password.1password.json" >"${DEST}/com.1password.1password.json"
    chmod 644 "${DEST}/com.1password.1password.json"
    echo "Done. Restart Brave completely (flatpak kill com.brave.Browser) to activate."
