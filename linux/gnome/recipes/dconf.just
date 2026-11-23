# vim: set ft=just :
# Per-user desktop settings. dconf load merges into the USER database
# (~/.config/dconf/user) — never the system db, so every setting stays
# user-level and survives OS rebases/switches.
#
# linux/gnome/dconf/ holds one keyfile per topic: desktop.ini, shell.ini,
# extensions.ini, apps.ini. All are applied by dconf-apply.

# Apply every linux/gnome/dconf/*.ini into the user database (idempotent).
[linux]
[group('desktop')]
dconf-apply:
    #!/usr/bin/env bash
    set -euo pipefail
    for f in "{{ repo_root }}"/linux/gnome/dconf/*.ini; do
        echo "==> dconf load: $(basename "$f")"
        dconf load / < "$f"
    done
    echo "dconf user settings applied. Log out/in (or restart apps) for some keys to take effect."

# Dump the current user settings into linux/gnome/dconf/proposals/ (gitignored),
# so manual GUI tweaks can be reviewed and merged by hand.
[linux]
[group('desktop')]
dconf-backup:
    #!/usr/bin/env bash
    set -euo pipefail
    dest="{{ repo_root }}/linux/gnome/dconf/proposals"
    mkdir -p "$dest"
    out="$dest/proposal-$(date +%Y%m%d-%H%M%S).ini"
    dconf dump / > "$out"
    echo "Current user settings dumped to $out"
    echo "Review the diff against linux/gnome/dconf/*.ini and merge what you want to keep."

# Reset a single key back to the image factory default (undo a repo setting).
# Usage: just dconf-reset /org/gnome/desktop/interface/cursor-theme
[linux]
[group('desktop')]
dconf-reset KEY:
    #!/usr/bin/env bash
    dconf reset "{{ KEY }}"
    echo "Reset {{ KEY }} to system default."

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
