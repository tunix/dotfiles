# vim: set ft=just :
# Homebrew. `brew bundle` without `upgrade` installs missing declarations
# only; upgrades are left to `brew upgrade` (or the image's timers).

# Install everything declared in the active layers' brew/*.Brewfile.
[group('apps')]
brew-sync:
    #!/bin/sh
    set -eu
    command -v brew >/dev/null 2>&1 || { echo "brew not found; nothing to sync on this host."; exit 0; }
    found=0
    for layer in {{ layers }}; do
        for f in "{{ repo_root }}/$layer"/brew/*.Brewfile; do
            [ -f "$f" ] || continue
            found=1
            echo "==> brew bundle: $layer/brew/$(basename "$f")"
            # Trust the Brewfile's `trusted: true` taps first: older brew
            # loads casks before it applies that option ("Refusing to load
            # cask ... from untrusted tap"). `brew trust` is idempotent.
            if brew trust --help >/dev/null 2>&1; then
                sed -nE 's/^[[:space:]]*tap[[:space:]]+["'"'"']([^"'"'"']+)["'"'"'].*trusted:[[:space:]]*true.*/\1/p' "$f" |
                    while read -r tap; do brew trust --tap "$tap" | grep -v '^Already trusted' || true; done
            fi
            brew bundle --file="$f"
        done
    done
    [ "$found" = 1 ] || echo "no Brewfiles in the active layers; nothing to do."

# Validate every Brewfile of every layer without evaluating them as Ruby.
[group('apps')]
brew-check:
    #!/bin/sh
    set -eu
    for d in $(cd "{{ repo_root }}" && find . -path ./.git -prune -o -type d -name brew -print | sed 's|^\./||' | sort); do
        echo "==> $d"
        bash "{{ repo_root }}/.scripts/validate-brewfiles.sh" "{{ repo_root }}/$d"
    done

# Upgrade every installed cask (casks are not covered by `brew upgrade`'s
# default auto-update handling).
[group('apps')]
update-brew-casks:
    #!/bin/sh
    set -eu
    for pkg in $(brew list --casks); do
        brew upgrade --cask "$pkg"
    done

alias ubc := update-brew-casks
