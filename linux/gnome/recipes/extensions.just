# vim: set ft=just :
# GNOME Shell extensions, user-installed (Extension Manager equivalent).
# Image-shipped extensions (tilingshell, tailscale-qs, appindicator,
# blur-my-shell, gsconnect, caffeine, ...) are NOT listed here: they come
# with the base image on Dakota/Bluefin and stay image-owned.

# Extensions that must be installed at user level on a fresh system.
# Settings for these live in linux/gnome/dconf/extensions.ini.
#
# Derived from the 2026-11 `dconf dump` + EGO shell_version_map checks:
# - grand-theft-focus: supports GNOME 50 natively.
# - solaar-extension: supports GNOME 50/51 (EGO v12); talks to flatpak
#   solaar over its exported session dbus interface.
# - theme-scheduler was dropped: color-scheme scheduling is handled by the
#   penguix-sun-scheduler systemd user timer (sun-based with a fixed
#   09:00/18:00 fallback).
# - search-light is intentionally NOT in this list: the dump shows it
#   disabled on the source machine; its tuned settings are kept in
#   extensions.ini for when it is re-enabled.
GNOME_USER_EXTENSIONS := "grand-theft-focus@zalckos.github.com solaar-extension@sidevesh"

# Install + enable every user extension (idempotent). A per-extension failure
# warns and setup continues, so one dead extension cannot block it; the
# extension's own output goes to the step's log.
[linux]
[group('desktop')]
extensions:
    #!/usr/bin/env bash
    set -euo pipefail
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init extensions
    installed=0
    inplace=0
    failed=0
    for uuid in {{ GNOME_USER_EXTENSIONS }}; do
        if out=$(ui_capture bash "{{ repo_root }}/.scripts/install-gnome-extension.sh" "$uuid"); then
            case $out in
                *"already installed"*) inplace=$((inplace + 1)) ;;
                *)
                    installed=$((installed + 1))
                    ui_note "installed $uuid"
                    ;;
            esac
        else
            failed=$((failed + 1))
            ui_note "$uuid could not be installed (log: $DOTFILES_LOGS/extensions.log)"
        fi
    done
    total=$((installed + inplace + failed))
    if [ "$failed" -gt 0 ]; then
        ui_warn "$failed of $(ui_plural "$total" extension extensions) failed; setup continues"
    elif [ "$installed" -gt 0 ]; then
        ui_note "log out/in if a new extension does not load (Wayland)"
        ui_upd "$installed installed, $inplace already in place"
    else
        ui_ok "$(ui_plural "$inplace" extension extensions) installed and enabled"
    fi

# Install one extension from extensions.gnome.org for the running GNOME
# Shell version, into ~/.local/share/gnome-shell/extensions/, then enable it.
[linux]
[group('desktop')]
extension-install UUID:
    #!/usr/bin/env bash
    set -euo pipefail
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init extension-install
    out=$(ui_capture bash "{{ repo_root }}/.scripts/install-gnome-extension.sh" "{{ UUID }}")
    case $out in
        *"already installed"*) ui_ok "{{ UUID }} already installed and enabled" ;;
        *) ui_upd "{{ UUID }} installed and enabled" ;;
    esac

# Disable a user extension without uninstalling it.
[linux]
[group('desktop')]
extension-disable UUID:
    #!/usr/bin/env bash
    set -euo pipefail
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init extension-disable
    ui_run gnome-extensions disable "{{ UUID }}"
    ui_upd "disabled {{ UUID }}"

# Uninstall a user extension entirely.
[linux]
[group('desktop')]
extension-uninstall UUID:
    #!/usr/bin/env bash
    set -euo pipefail
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init extension-uninstall
    rm -rf "$HOME/.local/share/gnome-shell/extensions/{{ UUID }}"
    ui_note "log out/in for the shell to forget it"
    ui_upd "removed {{ UUID }}"

# List installed extensions and their enabled state.
[linux]
[group('desktop')]
extensions-list:
    #!/usr/bin/env bash
    gnome-extensions list --enabled | sed 's/^/enabled:  /'
    gnome-extensions list --disabled | sed 's/^/disabled: /'
