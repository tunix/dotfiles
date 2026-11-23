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
