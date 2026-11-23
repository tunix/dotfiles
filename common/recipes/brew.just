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
            brew bundle --file="$f"
        done
    done
    [ "$found" = 1 ] || echo "no Brewfiles in the active layers; nothing to do."

# Validate every Brewfile of every layer without evaluating them as Ruby.
[group('apps')]
brew-check:
    #!/bin/sh
    set -eu
    for d in "{{ repo_root }}"/*/brew "{{ repo_root }}"/work/*/brew; do
        [ -d "$d" ] || continue
        echo "==> ${d#"{{ repo_root }}"/}"
        bash "{{ repo_root }}/lib/validate-brewfiles.sh" "$d"
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
