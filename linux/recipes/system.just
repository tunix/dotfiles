# vim: set ft=just :

# Change login shell for the current user. Fast-exits when the shell is
# already the target.
[linux]
[group('system')]
change-shell shell='/usr/bin/fish':
    #!/usr/bin/env bash
    set -euo pipefail
    user="$(id -un)"
    current="$(getent passwd "$user" | cut -d: -f7)"
    if [ "$current" = "{{ shell }}" ]; then
        echo "Login shell already {{ shell }}; nothing to do."
        exit 0
    fi
    sudo usermod --shell {{ shell }} "$user"

alias chsh := change-shell

# Install the Logitech udev rules Solaar needs so a user session can open the
# receivers/keyboards: without uaccess tags on /dev/hidraw* and /dev/uinput,
# neither the flatpak Solaar nor the solaar-extension backlight OSD can talk to
# the hardware (key remapping and rule actions fail silently). The flatpak's
# own --device=all cannot grant the shell, and Dakota is RPM-less so it ships
# no Logitech udev rules at all. Root is required because udev only reads
# rules from /etc/udev/rules.d. Fast-exits when the exact rule is already in
# place. This is a device/OS concern, not a GNOME one: the rule lives in the
# linux layer (linux/udev/), vendored byte-for-byte from pwr-Solaar/Solaar
# rules.d-uinput (Wayland variant)
# (sha256 b89e3105a1f2e6afb9a37081bead35e05b4f9e6db45394f68c59bd495fdbde44).
[linux]
[group('system')]
solaar-udev:
    #!/usr/bin/env bash
    set -euo pipefail
    src="{{ repo_root }}/linux/udev/42-logitech-unify-permissions.rules"
    dest="/etc/udev/rules.d/42-logitech-unify-permissions.rules"
    if [ -f "$dest" ] && cmp -s "$src" "$dest"; then
        echo "Logitech udev rules already installed ($dest); nothing to do."
        exit 0
    fi
    if ! gum confirm "Install Solaar's Logitech udev rules to $dest? (sudo)"; then
        exit 0
    fi
    sudo install -m 644 "$src" "$dest"
    sudo udevadm control --reload-rules
    sudo udevadm trigger --subsystem-match=hidraw --subsystem-match=misc
    echo "Installed $dest. Replug the Logitech receiver (or log out/in) to apply."

# Enable and start a systemd user unit that a layer ships in home/
# (~/.config/systemd/user/). Fast-exits when the unit is already enabled;
# without a user systemd session (e.g. over ssh) it warns and exits 0.
# Usage: just user-unit penguix-sun-scheduler.timer
[linux]
[group('system')]
user-unit unit:
    #!/usr/bin/env bash
    set -euo pipefail
    state="$(systemctl --user is-enabled "{{ unit }}" 2>/dev/null || true)"
    if [ "$state" = "enabled" ]; then
        echo "{{ unit }} already enabled; nothing to do."
        exit 0
    fi
    if ! systemctl --user daemon-reload 2>/dev/null; then
        echo "WARN: no user systemd session available; run 'just user-unit {{ unit }}' from a desktop session later." >&2
        exit 0
    fi
    systemctl --user enable --now "{{ unit }}"
    echo "{{ unit }} enabled."
