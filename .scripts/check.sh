#!/usr/bin/env bash
# .scripts/check.sh — validate the layer rules (`just check`).
#
#   .scripts/check.sh <repo-root>
#
# 1. Every host file parses on this OS, and the common layer parses ALONE
#    (a common recipe depending on an OS-specific one would break the other
#    OS: the whole justfile then fails to load).
# 2. Every recipe in an OS layer carries that OS's attribute
#    (linux, linux/gnome -> [linux]; macos -> [macos]).
# 3. Numbered files (compose fragments and native drop-ins such as
#    fish/conf.d, environment.d) use their layer's number band or the
#    shared final band 90-99, and no compose fragment name is used twice
#    for the same target.
# 4. Layers that are active together on a host never ship the same home/
#    path (the later one would silently win).
set -uo pipefail

root=${1:?usage: check.sh <repo-root>}
cd "$root"
errors=0
err() { echo "ERROR: $*" >&2; errors=$((errors + 1)); }
warn() { echo "WARN:  $*" >&2; }

# Layer -> number band. Plain functions instead of associative arrays:
# macOS still ships bash 3.2 as /bin/bash.
# A layer nested in another one (linux/gnome: a desktop environment on top
# of linux) is a layer of its own; hosts list both.
LAYERS="common linux linux/gnome macos work/cursor work/midas"
band_of() {
    case $1 in
        common) echo 00-09 ;; linux | macos) echo 10-19 ;; linux/gnome) echo 20-29 ;;
        work/cursor) echo 50-59 ;; work/midas) echo 70-79 ;; *) echo "" ;;
    esac
}
osattr_of() {
    case $1 in linux | linux/gnome) echo linux ;; macos) echo macos ;; *) echo "" ;; esac
}

layer_dirs() {
    for l in $LAYERS; do [ -d "$l" ] && echo "$l"; done
}

# ---------------------------------------------------------------- 1. parse
for h in hosts/*.just; do
    if ! out=$(just -f "$h" --summary 2>&1); then
        err "$h does not parse: $out"
    fi
done
tmpj=$(mktemp)
trap 'rm -f "$tmpj"' EXIT
cat > "$tmpj" <<EOF
repo_root := "$root"
host_file := "$tmpj"
layers := "common"
import "$root/common/recipes/main.just"
EOF
if ! out=$(just -f "$tmpj" --summary 2>&1); then
    err "common layer does not parse on its own (depends on an OS layer?): $out"
fi

# ------------------------------------------------------- 2. OS attributes
for l in $LAYERS; do
    want=$(osattr_of "$l")
    [ -n "$want" ] && [ -d "$l/recipes" ] || continue
    while IFS= read -r f; do
        awk -v want="$want" -v file="$f" '
            /^[[:space:]]*#/ || /^[[:space:]]*$/ { next }
            /^\[/ { attrs = attrs $0; next }
            /^[[:space:]]/ { next }
            /^(import|set|alias|export|mod)[[:space:]]/ { attrs = ""; next }
            /^[A-Za-z_][A-Za-z0-9_-]*[[:space:]]*:=/ { attrs = ""; next }
            /^@?_?[A-Za-z][A-Za-z0-9_-]*([[:space:]][^:]*)?:([[:space:]]|$)/ {
                name = $0; sub(/[[:space:]:].*/, "", name)
                if (attrs !~ "\\[" want "\\]") printf "%s: recipe %s lacks [%s]\n", file, name, want
                attrs = ""; next
            }
            { attrs = "" }
        ' "$f"
    done < <(find "$l/recipes" -name '*.just' | sort)
done > "$tmpj.attrs"
while IFS= read -r line; do err "$line"; done < "$tmpj.attrs"
rm -f "$tmpj.attrs"

# ------------------------------------------------- 3. numbering + duplicates
while IFS= read -r l; do
    band=$(band_of "$l")
    lo=${band%-*} hi=${band#*-}
    while IFS= read -r f; do
        n=$(basename "$f" | grep -oE '^[0-9]{2}' || true)
        [ -n "$n" ] || continue
        # 90-99 is the shared "final" band: files that must come after every
        # override (e.g. system PATH dirs after user-added ones)
        ((10#$n >= 90)) && continue
        if ((10#$n < 10#$lo || 10#$n > 10#$hi)); then
            err "$f: number $n outside $l band $band"
        fi
    done < <(find "$l/compose" "$l/home" -type f 2>/dev/null \
        | grep -E '/compose/|\.d/[0-9]{2}-' | grep -vE '/\.(mode|keep-existing)$')
    if [ -d "$l/compose" ]; then
        while IFS= read -r f; do
            case $(basename "$f") in [0-9][0-9]-*) ;; *) err "$f: compose fragment without NN- prefix" ;; esac
        done < <(find "$l/compose" -type f ! -name '.*')
    fi
done < <(layer_dirs)

# per host: same target + same fragment name across active layers
for h in hosts/*.just; do
    layers=$(sed -n 's/^layers := "\(.*\)"/\1/p' "$h")
    [ -n "$layers" ] || { err "$h: no layers line"; continue; }
    for l in $layers; do
        [ -n "$(band_of "$l")" ] || err "$h: unknown layer '$l' (add it to band_of in .scripts/check.sh)"
    done
    dup_frag=$(for l in $layers; do
        [ -d "$l/compose" ] && (cd "$l/compose" && find . -type f ! -name '.*')
    done | sort | uniq -d)
    [ -z "$dup_frag" ] || err "$h: compose fragment used by two layers: $dup_frag"
    # 4. home/ path collisions
    dup_home=$(for l in $layers; do
        [ -d "$l/home" ] && (cd "$l/home" && find . -type f | sed 's/\.tmpl$//')
    done | sort | uniq -d)
    [ -z "$dup_home" ] || err "$h: home/ path shipped by two active layers: $dup_home"
    # a home/ file and a compose target for the same path
    clash=$(comm -12 \
        <(for l in $layers; do [ -d "$l/home" ] && (cd "$l/home" && find . -type f | sed 's/\.tmpl$//'); done | sort -u) \
        <(for l in $layers; do [ -d "$l/compose" ] && (cd "$l/compose" && find . -type f ! -name '.*' -exec dirname {} \;); done | sort -u))
    [ -z "$clash" ] || err "$h: path is both a home/ file and a compose target: $clash"
done

# ssh reads the FIRST value it finds: precedence runs the other way there
if find . -path ./.git -prune -o -path '*/home/.ssh/config.d/*' -type f -print 2>/dev/null | grep -q .; then
    warn "ssh config.d drop-ins present: ssh keeps the FIRST value per option, so a lower number wins there"
fi

if [ "$errors" -gt 0 ]; then
    echo "check: $errors error(s)" >&2
    exit 1
fi
echo "check: OK ($(ls hosts/*.just | wc -l | tr -d ' ') hosts, $(layer_dirs | wc -l | tr -d ' ') layers)"
