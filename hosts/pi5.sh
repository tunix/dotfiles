#!/bin/sh
# hosts/pi5.sh — first-time setup for the Raspberry Pi 5 (Debian, no brew).
# Installs the bare minimum (just, pinned GitHub release, checksum-verified)
# into ~/.local/bin, fetches the repo, then hands off to hosts/pi5.just.
#
#   hosts/pi5.sh
#
# Idempotent: every step is skipped when already in place.
set -eu

JUST_VERSION=1.59.0
DOTFILES_DIR=${DOTFILES_DIR:-$HOME/dotfiles}
REPO_URL=https://github.com/tunix/dotfiles.git
BIN_DIR=$HOME/.local/bin

say() { printf '==> %s\n' "$*"; }

case "$(uname -s)-$(uname -m)" in
    Linux-aarch64) target=aarch64-unknown-linux-musl ;;
    *) echo "pi5.sh expects Linux on aarch64 (got $(uname -s)-$(uname -m))." >&2; exit 1 ;;
esac

# 1) just from the pinned GitHub release, verified against SHA256SUMS.
current=$("$BIN_DIR/just" --version 2>/dev/null | awk '{print $2}' || true)
if [ "$current" = "$JUST_VERSION" ]; then
    say "just $JUST_VERSION already installed; skipping."
else
    say "Installing just $JUST_VERSION into $BIN_DIR..."
    asset="just-$JUST_VERSION-$target.tar.gz"
    base="https://github.com/casey/just/releases/download/$JUST_VERSION"
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    curl -fsSL -o "$tmp/$asset" "$base/$asset"
    curl -fsSL -o "$tmp/SHA256SUMS" "$base/SHA256SUMS"
    (cd "$tmp" && grep " $asset\$" SHA256SUMS | sha256sum -c -) >/dev/null \
        || { echo "checksum mismatch for $asset" >&2; exit 1; }
    tar -xzf "$tmp/$asset" -C "$tmp" just
    mkdir -p "$BIN_DIR"
    install -m 755 "$tmp/just" "$BIN_DIR/just"
fi
case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *) export PATH="$BIN_DIR:$PATH" ;;
esac

# 2) The repo itself (git ships with Raspberry Pi OS).
if [ -d "$DOTFILES_DIR/.git" ]; then
    say "Repo already at $DOTFILES_DIR; skipping clone."
else
    say "Cloning dotfiles into $DOTFILES_DIR..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
fi

# 3) Hand off to the host file.
say "Running setup for host 'pi5'..."
exec just --justfile "$DOTFILES_DIR/hosts/pi5.just" setup
