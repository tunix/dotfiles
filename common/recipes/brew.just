# vim: set ft=just :
# Homebrew. `brew bundle` without `upgrade` installs missing declarations
# only; upgrades are left to `brew upgrade` (or the image's timers).

# Install everything declared in the active layers' brew/*.Brewfile.
# `brew bundle`'s own output goes to the step's log; only what it installed
# is reported.
[group('apps')]
brew-sync:
    #!/bin/sh
    set -eu
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init brew-sync
    if ! command -v brew >/dev/null 2>&1; then
        ui_skip "brew not installed on this host"
        exit 0
    fi
    files=0
    present=0
    new=0
    for layer in {{ layers }}; do
        for f in "{{ repo_root }}/$layer"/brew/*.Brewfile; do
            if [ ! -f "$f" ]; then continue; fi
            files=$((files + 1))
            rel=${f#"{{ repo_root }}/"}
            # Trust the Brewfile's `trusted: true` taps first: older brew
            # loads casks before it applies that option ("Refusing to load
            # cask ... from untrusted tap"). `brew trust` is idempotent and
            # best effort: the bundle call below fails loudly if a tap is
            # still untrusted.
            if brew trust --help >/dev/null 2>&1; then
                sed -nE 's/^[[:space:]]*tap[[:space:]]+["'"'"']([^"'"'"']+)["'"'"'].*trusted:[[:space:]]*true.*/\1/p' "$f" |
                    while read -r tap; do
                        brew trust --tap "$tap" >>"$DOTFILES_LOGS/brew-sync.log" 2>&1 || true
                    done
            fi
            ui_run brew bundle --file="$f"
            out=$ui_last_output
            p=$(printf '%s\n' "$out" | awk '/^Using /{n++} END{print n+0}')
            i=$(printf '%s\n' "$out" | awk '/^(Installing|Upgrading) /{n++} END{print n+0}')
            present=$((present + p))
            new=$((new + i))
            if [ "$i" -gt 0 ]; then
                ui_note "$rel: $i installed"
            fi
            # anything that is neither Using/Installing nor brew's own progress
            # chatter is worth showing (warnings, errors, notes)
            notable=$(printf '%s\n' "$out" |
                grep -vE '^(Using |Installing |Upgrading |==> |✔|`brew bundle` complete|$)' || true)
            if [ -n "$notable" ]; then
                ui_note "$(printf '%s\n' "$notable" | sed "s|^|$rel: |")"
            fi
        done
    done
    if [ "$files" = 0 ]; then
        ui_skip "no Brewfiles in the active layers"
    elif [ "$new" = 0 ]; then
        ui_ok "$present packages in $files Brewfiles, all present"
    else
        ui_upd "$new installed, $present present in $files Brewfiles"
    fi

# Validate every Brewfile of every layer without evaluating them as Ruby.
# The validator's per-package report goes to the step's log.
[group('apps')]
brew-check:
    #!/bin/sh
    set -eu
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init brew-check
    if ! command -v brew >/dev/null 2>&1; then
        ui_skip "brew not installed on this host"
        exit 0
    fi
    files=0
    for d in $(cd "{{ repo_root }}" && find . -path ./.git -prune -o -type d -name brew -print |
        sed 's|^\./||' | sort); do
        ui_run bash "{{ repo_root }}/.scripts/validate-brewfiles.sh" "{{ repo_root }}/$d"
        n=$(find "{{ repo_root }}/$d" -name '*.Brewfile' | wc -l | tr -d ' ')
        files=$((files + n))
    done
    if [ "$files" = 0 ]; then
        ui_skip "no Brewfiles in the repo"
    else
        ui_ok "$(ui_plural "$files" Brewfile Brewfiles) valid"
    fi

# Upgrade every installed cask (casks are not covered by `brew upgrade`'s
# default auto-update handling).
[group('apps')]
update-brew-casks:
    #!/bin/sh
    set -eu
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init update-brew-casks
    if ! command -v brew >/dev/null 2>&1; then
        ui_skip "brew not installed on this host"
        exit 0
    fi
    total=0
    upgraded=0
    failed=0
    for pkg in $(brew list --casks); do
        total=$((total + 1))
        if out=$(ui_capture brew upgrade --cask "$pkg"); then
            case $out in
                *Upgrading* | *Installing*)
                    upgraded=$((upgraded + 1))
                    ui_note "$pkg"
                    ;;
            esac
        else
            failed=$((failed + 1))
            ui_note "$pkg: upgrade failed (log: $DOTFILES_LOGS/update-brew-casks.log)"
        fi
    done
    if [ "$failed" -gt 0 ]; then
        ui_warn "$failed of $total casks failed to upgrade ($upgraded upgraded)"
    elif [ "$upgraded" = 0 ]; then
        ui_ok "$total casks, all up to date"
    else
        ui_upd "$upgraded of $total casks upgraded"
    fi

alias ubc := update-brew-casks
