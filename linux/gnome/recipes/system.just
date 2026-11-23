# vim: set ft=just :
# System-adjacent recipes. Everything here is per-user except the single
# opt-in sysctl tweak, which cannot exist at user level (sysctls are
# kernel-global) and is therefore gated behind an explicit confirmation.

# Update the OS (bootc) and offer a reboot.
[linux]
[group('system')]
update-and-reboot:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Updating system..."
    sudo bootc upgrade
    if gum confirm "Reboot now to apply updates?"; then
        systemctl reboot
    else
        echo "Update staged; apply on next reboot."
    fi

# Clean up podman images/containers/volumes.
[linux]
[group('system')]
clean-containers:
    #!/usr/bin/env bash
    echo "Cleaning up Podman containers, images, and volumes..."
    podman system prune -af
    podman volume prune -f
    echo "Cleanup complete!"

# OPTIONAL, opt-in: anti-fingerprinting default TTL. Needs root because
# sysctls are kernel-global; there is no userspace sysctl.
# Fast-exits when the setting is already in place.
[linux]
[group('system')]
sysctl-ttl:
    #!/usr/bin/env bash
    set -euo pipefail
    conf="/etc/sysctl.d/99-penguix-ttl.conf"
    if [ -f "$conf" ] && [ "$(cat "$conf")" = "net.ipv4.ip_default_ttl=65" ]; then
        echo "sysctl TTL already configured ($conf); nothing to do."
        exit 0
    fi
    if ! gum confirm "Write net.ipv4.ip_default_ttl=65 to $conf? (sudo)"; then
        exit 0
    fi
    printf 'net.ipv4.ip_default_ttl=65\n' | sudo tee "$conf" >/dev/null
    sudo sysctl --system
    echo "TTL applied. Reversal: sudo rm $conf && sudo sysctl --system"

# Show what of the desktop state is already applied.
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
