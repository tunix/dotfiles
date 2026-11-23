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
    set -euo pipefail
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init theme-sync
    if [ ! -x "$HOME/.local/bin/toggle-color-preferences.sh" ]; then
        ui_warn "toggle-color-preferences.sh missing; run 'just apply' (the unit only logs until then)"
    else
        ui_ok "ready (toggle-color-preferences.sh in place)"
    fi

# Re-evaluate color-scheme every minute from local sunrise/sunset
# (penguix-sun-scheduler user timer) and apply the current answer right away,
# so `setup`/`apply` never leaves the session in the wrong mode while the
# timer waits for its next tick. This recipe is the ONLY writer of
# color-scheme — it is deliberately absent from linux/gnome/dconf/desktop.ini,
# so a dconf-apply cannot flip it back to a fixed scheme. Location comes from
# night-light-last-coordinates (gsd writes it when Night Light follows the
# system location); fallback: fixed 09:00 light / 18:00 dark.
[linux]
[group('desktop')]
sun-scheduler: (user-unit "penguix-sun-scheduler.timer")
    #!/usr/bin/env bash
    set -euo pipefail
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init sun-scheduler
    bin="$HOME/.local/bin/penguix-sun-scheduler"
    if [ ! -f "$bin" ]; then
        ui_fail "$bin missing; run 'just apply' first"
        exit 1
    fi
    # A script in ~/.local/bin is exec'd by the unit: without its executable
    # bit systemd fails every tick with 203/EXEC, silently. Restore it and
    # say so (a lost bit in the repo itself is caught by `just check`).
    if [ ! -x "$bin" ]; then
        chmod +x "$bin"
        ui_note "restored the executable bit on ~/.local/bin/penguix-sun-scheduler"
    fi
    # Decide now instead of leaving the dconf default in place until the next
    # minute tick: light during local daytime, dark otherwise.
    if out=$("$bin" 2>&1); then
        case $out in
            *"already active"*) ui_ok "color scheme follows sunrise/sunset" ;;
            *) ui_note "$out"; ui_upd "color scheme set from sunrise/sunset" ;;
        esac
    else
        ui_warn "could not evaluate the sun schedule now (no session bus?); the timer will set it"
    fi

# Install a Bibata cursor theme variant into ~/.local/share/icons (userspace)
# and select it. Fast-exits when the variant is already installed.
# Variants: Modern/Original x Ice (white)/Classic (black)/Amber (yellow),
# optional -Right (right-pointing). Release pinned: ful1e5/Bibata_Cursor v2.0.7.
[linux]
[group('desktop')]
bibata variant='Bibata-Modern-Ice':
    #!/usr/bin/env bash
    set -euo pipefail
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init bibata
    did=0
    dest="$HOME/.local/share/icons/{{ variant }}"
    if [ -f "$dest/index.theme" ]; then
        : # already installed
    else
        ver="v2.0.7"
        url="https://github.com/ful1e5/Bibata_Cursor/releases/download/${ver}/{{ variant }}.tar.xz"
        tmp="$(mktemp -d)"
        trap 'rm -rf "$tmp"' EXIT
        ui_run curl -fsSL -o "$tmp/theme.tar.xz" "$url"
        mkdir -p "$HOME/.local/share/icons"
        tar -xf "$tmp/theme.tar.xz" -C "$HOME/.local/share/icons/"
        if [ ! -f "$dest/index.theme" ]; then
            ui_fail "unexpected tarball layout (no $dest/index.theme)"
            exit 1
        fi
        ui_note "installed {{ variant }} (${ver}) into ~/.local/share/icons"
        did=1
    fi
    current="$(gsettings get org.gnome.desktop.interface cursor-theme 2>/dev/null || true)"
    if [ "$current" != "'{{ variant }}'" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme '{{ variant }}'
        ui_note "cursor-theme set; log out/in for every app to pick it up"
        did=1
    fi
    if [ "$did" = 1 ]; then
        ui_upd "{{ variant }} installed and selected"
    else
        ui_ok "{{ variant }} already installed and selected"
    fi
