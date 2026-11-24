# vim: set ft=just :
# Applications and app integrations that are not plain Brewfile entries.
# Nothing here is GNOME-specific: the flatpak remote, the Toolbox tarball and
# the Brave/1Password flatpak wiring work on any Linux desktop.

# Add the user-level Flathub remote that linux/brew/flatpak.Brewfile
# installs from (brew-sync runs after this in setup). Idempotent.
[linux]
[group('apps')]
flatpak-remote:
    #!/bin/sh
    set -eu
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init flatpak-remote
    if ! command -v flatpak >/dev/null 2>&1; then
        ui_skip "flatpak not installed"
        exit 0
    fi
    if flatpak remotes --user --columns=name 2>/dev/null | grep -qx flathub; then
        ui_ok "flathub user remote present"
        exit 0
    fi
    ui_run flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    ui_upd "added the flathub user remote"

# Install JetBrains Toolbox (user-level, no layering).
[linux]
[group('apps')]
install-jetbrains-toolbox:
    #!/usr/bin/env bash
    set -euo pipefail
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init install-jetbrains-toolbox
    work="$(mktemp -d)"
    trap 'rm -rf "$work"' EXIT
    ui_run curl -sSfL -o "$work/releases.json" \
        "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release"
    BUILD_VERSION=$(jq -r '.TBA[0].build' "$work/releases.json")
    DOWNLOAD_LINK=$(jq -r '.TBA[0].downloads.linux.link' "$work/releases.json")
    CHECKSUM_LINK=$(jq -r '.TBA[0].downloads.linux.checksumLink' "$work/releases.json")
    (cd "$work" && curl -sSfL -O "${DOWNLOAD_LINK}")
    (cd "$work" && curl -sSfL "${CHECKSUM_LINK}" | sha256sum -c >/dev/null)
    tar zxf "$work/jetbrains-toolbox-${BUILD_VERSION}.tar.gz" -C "$work"
    mkdir -p "$HOME/.local/share/JetBrains/ToolboxApp/"
    mv "$work/jetbrains-toolbox-${BUILD_VERSION}"/* "$HOME/.local/share/JetBrains/ToolboxApp/"
    "$HOME/.local/share/JetBrains/ToolboxApp/bin/jetbrains-toolbox" &
    ui_upd "JetBrains Toolbox $BUILD_VERSION installed and started"

# Install the AWS Session Manager plugin into ~/.local/bin when the AWS CLI
# is present (extracted from AWS's RPM with Homebrew's rpm2cpio + cpio).
# Fast-exits when the plugin is installed or the AWS CLI is missing.
[linux]
[group('apps')]
aws-session-manager:
    #!/usr/bin/env bash
    set -euo pipefail
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
    if ! command -v rpm2cpio >/dev/null; then ui_run brew install rpm; fi
    if ! command -v cpio >/dev/null; then ui_run brew install cpio; fi
    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' EXIT
    ui_run curl -fsSL -o "$tmp/plugin.rpm" \
        https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm
    (cd "$tmp" && rpm2cpio plugin.rpm | cpio -idm --quiet)
    mkdir -p "$HOME/.local/bin"
    install -m 755 "$tmp/usr/local/sessionmanagerplugin/bin/session-manager-plugin" "$bin"
    ui_upd "installed ~/.local/bin/session-manager-plugin"

# Enable 1Password desktop integration for the Brave flatpak. Requires the
# 1Password GUI (linux/brew/apps.Brewfile). The talk-name override also ships
# as a file (linux/home/.local/share/flatpak/overrides/com.brave.Browser)
# deployed by `just apply`; this recipe re-asserts it via the flatpak CLI and
# installs the native messaging host, which depends on the 1Password install.
[linux]
[group('apps')]
brave-1password-fix:
    #!/usr/bin/env bash
    set -euo pipefail
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init brave-1password-fix
    SRC="$HOME/.config/BraveSoftware/Brave-Browser/NativeMessagingHosts"
    DEST="$HOME/.var/app/com.brave.Browser/config/BraveSoftware/Brave-Browser/NativeMessagingHosts"
    OVERRIDE="$HOME/.local/share/flatpak/overrides/com.brave.Browser"
    if [ ! -f "${SRC}/1PasswordWrapper.sh" ] || [ ! -f "${SRC}/com.1password.1password.json" ]; then
        ui_fail "1Password native messaging files not found in $SRC; install the GUI first: just brew-sync"
        exit 1
    fi
    if [ -f "${DEST}/1PasswordWrapper.sh" ] && [ -f "${DEST}/com.1password.1password.json" ] \
        && grep -q 'talk-name=org.freedesktop.Flatpak' "$OVERRIDE" 2>/dev/null; then
        ui_ok "1Password integration for the Brave flatpak already in place"
        exit 0
    fi
    ui_run flatpak override --user --talk-name=org.freedesktop.Flatpak com.brave.Browser
    mkdir -p "${DEST}"
    install -m 755 "${SRC}/1PasswordWrapper.sh" "${DEST}/1PasswordWrapper.sh"
    sed -E "s|\"path\": \".*\"|\"path\": \"${DEST}/1PasswordWrapper.sh\"|" \
        "${SRC}/com.1password.1password.json" >"${DEST}/com.1password.1password.json"
    chmod 644 "${DEST}/com.1password.1password.json"
    ui_note "restart Brave completely (flatpak kill com.brave.Browser) to activate"
    ui_upd "1Password integration installed for the Brave flatpak"

# Install the flatpak Solaar's config so it keeps the settings and key-remap
# rules from the pre-flatpak native install. The sandbox maps
# ~/.var/app/io.github.pwr_solaar.solaar/config to $HOME/.config, so its state
# lives at .../config/solaar/ and it can neither see nor write the legacy
# ~/.config/solaar/ — a fresh flatpak silently starts with default device
# settings and no rules. rules.yaml (the user-authored remaps) is dotfiles-
# owned and deployed by `just apply` from linux/home/.var/app/...; config.yaml
# is per-device state Solaar rewrites at runtime, so this recipe only copies
# it across when the flatpak has no config yet (e.g. first setup). Also
# refreshes the user icon cache for the vendored "solaar" tray icon
# (linux/home/.local/share/icons/hicolor/scalable/apps/solaar.svg): the
# flatpak renamed its icons to io.github.pwr_solaar.solaar* while the tray
# still asks for legacy "solaar", which otherwise falls back to
# image-loading-symbolic — the three-dot icon. Idempotent.
[linux]
[group('apps')]
solaar-config:
    #!/usr/bin/env bash
    set -euo pipefail
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init solaar-config
    fc="$HOME/.var/app/io.github.pwr_solaar.solaar/config/solaar"
    legacy="$HOME/.config/solaar"
    did=0
    if [ -f "$legacy/config.yaml" ] && [ ! -f "$fc/config.yaml" ]; then
        mkdir -p "$fc"
        install -m 644 "$legacy/config.yaml" "$fc/config.yaml"
        ui_note "migrated legacy ~/.config/solaar/config.yaml into the flatpak config"
        did=1
    fi
    icon="$HOME/.local/share/icons/hicolor/scalable/apps/solaar.svg"
    cache="$HOME/.local/share/icons/hicolor/icon-theme.cache"
    if [ -f "$icon" ] && { [ ! -f "$cache" ] || [ "$icon" -nt "$cache" ]; }; then
        gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" >/dev/null 2>&1 || true
        ui_note "user icon cache refreshed for the Solaar tray icon"
        did=1
    elif [ ! -f "$icon" ]; then
        ui_warn "tray icon missing; run 'just apply' (deploys linux/home/.local/share/icons/hicolor/scalable/apps/solaar.svg)"
    fi
    if [ "$did" = 1 ]; then
        ui_note "restart Solaar (flatpak kill io.github.pwr_solaar.solaar) to pick up the config"
        ui_upd "Solaar flatpak config and tray icon in place"
    else
        ui_ok "Solaar flatpak config and tray icon already in place"
    fi
