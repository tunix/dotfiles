# vim: set ft=just :
# pi layer: Raspberry Pi (Debian/Raspberry Pi OS, no Homebrew). Every recipe
# carries [linux] (`just check` enforces it).

# Debian packages for the Pi (formerly pi5.yml `packages`). jq is required by
# `just apply` for JSON fragments.
PI_PACKAGES := "bat btop containerd.io direnv docker-buildx-plugin docker-ce docker-ce-cli docker-compose-plugin exa fish git htop httpie jq neovim silversearcher-ag zoxide"

# Add the Docker apt repository (key + source list). Fast-exits when both
# are already in place.
[linux]
[group('system')]
apt-repos:
    #!/usr/bin/env bash
    set -euo pipefail
    key=/etc/apt/keyrings/docker.asc
    list=/etc/apt/sources.list.d/docker.list
    line="deb [arch=arm64 signed-by=$key] https://download.docker.com/linux/debian bookworm stable"
    if [ -f "$key" ] && [ -f "$list" ] && grep -qxF "$line" "$list"; then
        echo "docker apt repository already configured; nothing to do."
        exit 0
    fi
    sudo install -d -m 755 /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o "$key"
    echo "$line" | sudo tee "$list" >/dev/null
    sudo apt-get update

# Install the Pi's Debian packages. Fast-exits when all are installed.
[linux]
[group('system')]
apt-packages: apt-repos
    #!/usr/bin/env bash
    set -euo pipefail
    missing=()
    for p in {{ PI_PACKAGES }}; do
        dpkg-query -W -f='${Status}' "$p" 2>/dev/null | grep -q "install ok installed" || missing+=("$p")
    done
    if [ ${#missing[@]} -eq 0 ]; then
        echo "all Pi packages installed; nothing to do."
        exit 0
    fi
    sudo apt-get install -y "${missing[@]}"
