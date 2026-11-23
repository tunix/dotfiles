# vim: set ft=just :
# Linux layer: OS-level, device-level and CLI state that any desktop needs.
# Only the three recipes that cannot work per-user take root (`solaar-udev`,
# `sysctl-ttl`, `update-and-reboot`); everything else stays in $HOME.

# Change login shell for the current user. Fast-exits when the shell is
# already the target.
[linux]
[group('system')]
change-shell shell='/usr/bin/fish':
    #!/usr/bin/env bash
    set -euo pipefail
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init change-shell
    user="$(id -un)"
    current="$(getent passwd "$user" | cut -d: -f7)"
    if [ "$current" = "{{ shell }}" ]; then
        ui_ok "already {{ shell }}"
        exit 0
    fi
    sudo usermod --shell {{ shell }} "$user"
    ui_upd "login shell $current -> {{ shell }}"

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
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init solaar-udev
    src="{{ repo_root }}/linux/udev/42-logitech-unify-permissions.rules"
    dest="/etc/udev/rules.d/42-logitech-unify-permissions.rules"
    if [ -f "$dest" ] && cmp -s "$src" "$dest"; then
        ui_ok "Logitech udev rules already installed ($dest)"
        exit 0
    fi
    if ! gum confirm "Install Solaar's Logitech udev rules to $dest? (sudo)"; then
        ui_skip "declined"
        exit 0
    fi
    sudo install -m 644 "$src" "$dest"
    sudo udevadm control --reload-rules
    sudo udevadm trigger --subsystem-match=hidraw --subsystem-match=misc
    ui_note "replug the Logitech receiver (or log out/in) to apply"
    ui_upd "installed $dest"

# Enable and start a systemd user unit that a layer ships in home/
# (~/.config/systemd/user/). Fast-exits when the unit is already enabled;
# without a user systemd session (e.g. over ssh) it warns and exits 0.
# Usage: just user-unit penguix-sun-scheduler.timer
[linux]
[group('system')]
user-unit unit:
    #!/usr/bin/env bash
    set -euo pipefail
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init user-unit
    state="$(systemctl --user is-enabled "{{ unit }}" 2>/dev/null || true)"
    if [ "$state" = "enabled" ]; then
        ui_ok "{{ unit }} already enabled"
        exit 0
    fi
    if ! systemctl --user daemon-reload 2>/dev/null; then
        ui_warn "no user systemd session; run 'just user-unit {{ unit }}' from a desktop session"
        exit 0
    fi
    systemctl --user enable --now "{{ unit }}"
    ui_upd "{{ unit }} enabled"

# Update the OS (bootc) and offer a reboot.
[linux]
[group('system')]
update-and-reboot:
    #!/usr/bin/env bash
    set -euo pipefail
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init update-and-reboot
    sudo bootc upgrade
    if gum confirm "Reboot now to apply updates?"; then
        systemctl reboot
    else
        ui_upd "update staged; apply on next reboot"
    fi

# Clean up podman images/containers/volumes.
[linux]
[group('system')]
clean-containers:
    #!/usr/bin/env bash
    set -euo pipefail
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init clean-containers
    podman system prune -af
    podman volume prune -f
    ui_upd "podman images, containers and volumes pruned"

# OPTIONAL, opt-in: anti-fingerprinting default TTL. Needs root because
# sysctls are kernel-global; there is no userspace sysctl.
# Fast-exits when the setting is already in place.
[linux]
[group('system')]
sysctl-ttl:
    #!/usr/bin/env bash
    set -euo pipefail
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init sysctl-ttl
    conf="/etc/sysctl.d/99-penguix-ttl.conf"
    if [ -f "$conf" ] && [ "$(cat "$conf")" = "net.ipv4.ip_default_ttl=65" ]; then
        ui_ok "already configured ($conf)"
        exit 0
    fi
    if ! gum confirm "Write net.ipv4.ip_default_ttl=65 to $conf? (sudo)"; then
        ui_skip "declined"
        exit 0
    fi
    printf 'net.ipv4.ip_default_ttl=65\n' | sudo tee "$conf" >/dev/null
    sudo sysctl --system >/dev/null
    ui_note "reversal: sudo rm $conf && sudo sysctl --system"
    ui_upd "net.ipv4.ip_default_ttl=65 written to $conf and applied"

# Show what of the repo state is already applied on this machine.
[linux]
[group('system')]
status:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "brew:"
    command -v brew >/dev/null && brew list --formula -1 | wc -l | xargs echo "  formulas:" || echo "  brew not installed yet"
    echo "flatpaks (user):"
    flatpak list --user --app --columns=application 2>/dev/null | sed 's/^/  /'
    echo "user shell extensions:"
    ls -1 "$HOME/.local/share/gnome-shell/extensions" 2>/dev/null | sed 's/^/  /'
    echo "dconf user settings: $([ -s "$HOME/.config/dconf/user" ] 2>/dev/null && echo present || echo empty)"
    echo "brave flags: $([ -f "$HOME/.var/app/com.brave.Browser/config/brave-flags.conf" ] && echo deployed || echo missing)"
