#!/bin/sh
# .scripts/summary.sh — the closing tally of a `setup` run.
#
#   summary.sh [note]
#
# Counts the step lines this run appended to $DOTFILES_REPORT (see ui.sh) and
# prints one line. `note` is printed under it, but only when the run actually
# changed something (there is nothing to do about a no-op run).
set -eu

report=${DOTFILES_REPORT:-${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/status.tsv}
run=${DOTFILES_RUN:-standalone}
note=${1:-}

if [ ! -f "$report" ]; then
    echo
    echo "setup  no steps reported"
    exit 0
fi

set -- $(awk -F'\t' -v r="$run" '$1 == r { n++; c[$2]++ }
    END { print n + 0, c["ok"] + 0, c["upd"] + 0, c["skip"] + 0, c["warn"] + 0, c["fail"] + 0 }' \
    "$report")
total=$1 ok=$2 upd=$3 skip=$4 warn=$5 fail=$6

changed=$(awk -F'\t' -v r="$run" '$1 == r && $2 == "upd" { if (!seen[$3]++) { printf "%s%s", sep, $3; sep = ", " } }' \
    "$report")

parts=
add_part() {
    if [ -z "$parts" ]; then parts=$1; else parts="$parts · $1"; fi
}
if [ "$upd" -gt 0 ]; then
    add_part "$upd changed"
    if [ -n "$changed" ]; then parts="$parts ($changed)"; fi
else
    add_part "everything already in place"
fi
if [ "$skip" -gt 0 ]; then add_part "$skip skipped"; fi
if [ "$warn" -gt 0 ]; then add_part "$warn warning(s)"; fi
if [ "$fail" -gt 0 ]; then add_part "$fail failed"; fi

echo
echo "setup  $total step(s) · $parts"
if [ -n "$note" ] && [ "$upd" -gt 0 ]; then
    echo "       $note"
fi
