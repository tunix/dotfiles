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
