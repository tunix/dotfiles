# vim: set ft=just :
# Applications and app integrations that are not plain Brewfile entries.
# Nothing here is GNOME-specific: the flatpak remote, the Toolbox tarball and
# the Brave/1Password flatpak wiring work on any Linux desktop.

# Add the user-level Flathub remote that linux/brew/flatpak.Brewfile
# installs from (brew-sync runs after this in setup). Idempotent.
[linux]
[group('apps')]
flatpak-remote:
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install JetBrains Toolbox (user-level, no layering).
[linux]
[group('apps')]
install-jetbrains-toolbox:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Installing JetBrains Toolbox..."
    pushd "$(mktemp -d)"
    curl -sSfL -o releases.json "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release"
    BUILD_VERSION=$(jq -r '.TBA[0].build' ./releases.json)
    DOWNLOAD_LINK=$(jq -r '.TBA[0].downloads.linux.link' ./releases.json)
    CHECKSUM_LINK=$(jq -r '.TBA[0].downloads.linux.checksumLink' ./releases.json)
    echo "Installing JetBrains Toolbox ${BUILD_VERSION}"
    curl -sSfL -O "${DOWNLOAD_LINK}"
    curl -sSfL "${CHECKSUM_LINK}" | sha256sum -c
    tar zxf jetbrains-toolbox-"${BUILD_VERSION}".tar.gz
    mkdir -p "$HOME/.local/share/JetBrains/ToolboxApp/"
    mv jetbrains-toolbox-"${BUILD_VERSION}"/* "$HOME/.local/share/JetBrains/ToolboxApp/"
    popd
    "$HOME/.local/share/JetBrains/ToolboxApp/bin/jetbrains-toolbox" &

# Install the AWS Session Manager plugin into ~/.local/bin when the AWS CLI
# is present (extracted from AWS's RPM with Homebrew's rpm2cpio + cpio).
# Fast-exits when the plugin is installed or the AWS CLI is missing.
[linux]
[group('apps')]
aws-session-manager:
    #!/usr/bin/env bash
    set -euo pipefail
    bin="$HOME/.local/bin/session-manager-plugin"
    if [ -x "$bin" ]; then
        echo "session-manager-plugin already installed; nothing to do."
        exit 0
    fi
    if ! command -v aws >/dev/null; then
        echo "AWS CLI not installed; nothing to do."
        exit 0
    fi
    command -v rpm2cpio >/dev/null || brew install rpm
    command -v cpio >/dev/null || brew install cpio
    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' EXIT
    curl -fsSL -o "$tmp/plugin.rpm" \
        https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm
    (cd "$tmp" && rpm2cpio plugin.rpm | cpio -idm --quiet)
    mkdir -p "$HOME/.local/bin"
    install -m 755 "$tmp/usr/local/sessionmanagerplugin/bin/session-manager-plugin" "$bin"
    echo "Installed $bin"

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
    SRC="$HOME/.config/BraveSoftware/Brave-Browser/NativeMessagingHosts"
    DEST="$HOME/.var/app/com.brave.Browser/config/BraveSoftware/Brave-Browser/NativeMessagingHosts"
    OVERRIDE="$HOME/.local/share/flatpak/overrides/com.brave.Browser"
    if [ ! -f "${SRC}/1PasswordWrapper.sh" ] || [ ! -f "${SRC}/com.1password.1password.json" ]; then
        echo "1Password native messaging files not found in ${SRC}." >&2
        echo "Install the GUI first: just brew-sync" >&2
        exit 1
    fi
    if [ -f "${DEST}/1PasswordWrapper.sh" ] && [ -f "${DEST}/com.1password.1password.json" ] \
        && grep -q 'talk-name=org.freedesktop.Flatpak' "$OVERRIDE" 2>/dev/null; then
        echo "1Password integration for the Brave flatpak already in place; nothing to do."
        exit 0
    fi
    flatpak override --user --talk-name=org.freedesktop.Flatpak com.brave.Browser
    mkdir -p "${DEST}"
    install -m 755 "${SRC}/1PasswordWrapper.sh" "${DEST}/1PasswordWrapper.sh"
    sed -E "s|\"path\": \".*\"|\"path\": \"${DEST}/1PasswordWrapper.sh\"|" \
        "${SRC}/com.1password.1password.json" >"${DEST}/com.1password.1password.json"
    chmod 644 "${DEST}/com.1password.1password.json"
    echo "Done. Restart Brave completely (flatpak kill com.brave.Browser) to activate."
