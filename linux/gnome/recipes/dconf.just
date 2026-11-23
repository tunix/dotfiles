# vim: set ft=just :
# Per-user desktop settings. dconf load merges into the USER database
# (~/.config/dconf/user) — never the system db, so every setting stays
# user-level and survives OS rebases/switches.
#
# linux/gnome/dconf/ holds one keyfile per topic: desktop.ini, shell.ini,
# extensions.ini, apps.ini. All are applied by dconf-apply.

# Apply every linux/gnome/dconf/*.ini into the user database (idempotent:
# the user db is dumped before and after, so a no-op run says so).
[linux]
[group('desktop')]
dconf-apply:
    #!/usr/bin/env bash
    set -euo pipefail
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init dconf-apply
    if ! command -v dconf >/dev/null 2>&1; then
        ui_skip "dconf not installed"
        exit 0
    fi
    if ! before=$(ui_capture dconf dump /); then
        ui_fail "dconf dump failed (no session bus?)"
        exit 1
    fi
    n=0
    for f in "{{ repo_root }}"/linux/gnome/dconf/*.ini; do
        dconf load / <"$f"
        n=$((n + 1))
    done
    after=$(ui_capture dconf dump / || true)
    if [ "$before" = "$after" ]; then
        ui_ok "$n dconf files, settings already in place"
    else
        ui_upd "$n dconf files loaded, settings changed"
    fi

# Dump the current user settings into linux/gnome/dconf/proposals/ (gitignored),
# so manual GUI tweaks can be reviewed and merged by hand.
[linux]
[group('desktop')]
dconf-backup:
    #!/usr/bin/env bash
    set -euo pipefail
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init dconf-backup
    dest="{{ repo_root }}/linux/gnome/dconf/proposals"
    mkdir -p "$dest"
    out="$dest/proposal-$(date +%Y%m%d-%H%M%S).ini"
    dconf dump / >"$out"
    ui_note "diff it against linux/gnome/dconf/*.ini and merge what you want to keep"
    ui_upd "$(basename "$out") written to linux/gnome/dconf/proposals/"

# Reset a single key back to the image factory default (undo a repo setting).
# Usage: just dconf-reset /org/gnome/desktop/interface/cursor-theme
[linux]
[group('desktop')]
dconf-reset KEY:
    #!/usr/bin/env bash
    set -euo pipefail
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init dconf-reset
    dconf reset "{{ KEY }}"
    ui_upd "reset {{ KEY }} to the system default"

# Compare the live user db against TRUE schema defaults (read-only).
# Uses an empty dconf profile so gsettings returns compiled schema defaults
# instead of effective values. Buckets: SAME-AS-DEFAULT (safe to reset,
# per repo file, with the exact dconf reset command), DIFFERS (keep),
# UNKNOWN (extension/app schemas the script cannot judge).
[linux]
[group('desktop')]
dconf-vs-defaults:
    #!/usr/bin/env bash
    set -euo pipefail
    python3 "{{ repo_root }}/.scripts/dconf-vs-defaults.py"
