#!/bin/bash
# .scripts/bootstrap-mac.sh — first-time setup for macOS. Installs the bare
# minimum (Homebrew + just), fetches the repo, then hands off to the host's
# justfile. Everything else (fish, git config, apps ...) is installed by
# `just setup` via Brewfiles.
#
# Fresh Mac:
#   curl -fsSL https://raw.githubusercontent.com/tunix/dotfiles/main/.scripts/bootstrap-mac.sh | bash
# Existing checkout:
#   .scripts/bootstrap-mac.sh          (uses hosts/mac.just)
#   .scripts/bootstrap-mac.sh <host>   (uses hosts/<host>.just)
#
# Idempotent: every step is skipped when already in place.
set -euo pipefail

DOTFILES_DIR=${DOTFILES_DIR:-$HOME/Projects/dotfiles}
REPO_URL=https://github.com/tunix/dotfiles.git

say() { printf '==> %s\n' "$*"; }

if [ "$(uname -s)" != "Darwin" ]; then
    echo "bootstrap-mac.sh is for macOS only. On Linux, brew and just ship with the image:" >&2
    echo "  just -f hosts/<host>.just setup    (e.g. hosts/penguix.just)" >&2
    exit 1
fi

# 1) Homebrew. Its official installer also installs the Xcode Command Line
#    Tools when missing, which provides git for step 3.
if command -v brew >/dev/null 2>&1; then
    say "Homebrew already installed; skipping."
else
    say "Installing Homebrew (asks for your password once)..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
for prefix in /opt/homebrew /usr/local; do
    if [ -x "$prefix/bin/brew" ]; then
        eval "$("$prefix/bin/brew" shellenv)"
        break
    fi
done
command -v brew >/dev/null 2>&1 || { echo "brew not found after install." >&2; exit 1; }

# 2) just — the only tool installed here; the rest comes from the Brewfiles.
if command -v just >/dev/null 2>&1; then
    say "just already installed; skipping."
else
    say "Installing just..."
    brew install just
fi

# 3) The repo itself (submodules are fetched by the host file when needed).
if [ -d "$DOTFILES_DIR/.git" ]; then
    say "Repo already at $DOTFILES_DIR; skipping clone."
else
    say "Cloning dotfiles into $DOTFILES_DIR..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
fi

# 4) Hand off to the host file. Host files are named by role, not by
#    hostname (macOS hostnames are asset tags). Default: hosts/mac.just;
#    override with an argument (bootstrap-mac.sh <host>) or DOTFILES_HOST.
host=${1:-${DOTFILES_HOST:-mac}}
hostfile="$DOTFILES_DIR/hosts/$host.just"
if [ ! -f "$hostfile" ]; then
    echo "No host file '$host' ($hostfile)." >&2
    echo "Available hosts:" >&2
    ls "$DOTFILES_DIR/hosts" 2>/dev/null | sed 's/\.just$//; s/^/  /' >&2
    exit 1
fi
say "Running setup for host '$host'..."
exec just -f "$hostfile" setup
