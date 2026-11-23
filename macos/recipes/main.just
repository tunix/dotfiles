# vim: set ft=just :
# macos layer. Every recipe carries [macos] (`just check` enforces it).

# Anti-fingerprinting default TTL (net.inet.ip.ttl=65): sets the live value
# and persists it in /etc/sysctl.conf. Needs sudo. Fast-exits when both
# already match.
[macos]
[group('system')]
sysctl-ttl:
    #!/bin/sh
    set -eu
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init sysctl-ttl
    live=$(sysctl -n net.inet.ip.ttl)
    if [ "$live" = 65 ] && grep -qx 'net.inet.ip.ttl=65' /etc/sysctl.conf 2>/dev/null; then
        ui_ok "net.inet.ip.ttl already 65"
        exit 0
    fi
    sudo sysctl -w net.inet.ip.ttl=65 >/dev/null
    if ! grep -qx 'net.inet.ip.ttl=65' /etc/sysctl.conf 2>/dev/null; then
        echo 'net.inet.ip.ttl=65' | sudo tee -a /etc/sysctl.conf >/dev/null
    fi
    ui_upd "net.inet.ip.ttl=65 applied and persisted in /etc/sysctl.conf"

# Install the AWS Session Manager plugin into ~/.local/bin when the AWS CLI
# is present. Fast-exits when the plugin is installed or the CLI is missing.
[macos]
[group('apps')]
aws-session-manager:
    #!/bin/sh
    set -eu
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init aws-session-manager
    bin="$HOME/.local/bin/session-manager-plugin"
    if [ -x "$bin" ]; then
        ui_ok "session-manager-plugin installed"
        exit 0
    fi
    if ! command -v aws >/dev/null; then
        ui_skip "AWS CLI not installed"
        exit 0
    fi
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    ui_run curl -fsSL -o "$tmp/bundle.zip" \
        https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac_arm64/sessionmanager-bundle.zip
    (cd "$tmp" && unzip -q bundle.zip)
    mkdir -p "$HOME/.local/bin"
    "$tmp/sessionmanager-bundle/install" -i "$HOME/.local/sessionmanagerplugin" -b "$bin"
    ui_upd "installed ~/.local/bin/session-manager-plugin"
