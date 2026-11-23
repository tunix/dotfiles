#!/bin/sh
# .scripts/apply.sh — deploy the active layers into $HOME.
#
#   .scripts/apply.sh <repo-root> <layer> [<layer> ...]
#
# Layers are applied in the order given (common first, work last). Each
# layer may contain:
#
#   home/     Files copied to the same path under $HOME. A later layer wins
#             on an identical path. Files ending in `.tmpl` have `@HOME@`
#             replaced with $HOME and are installed without the suffix.
#             Native drop-in directories (fish conf.d, environment.d, ...)
#             simply receive one numbered file per layer.
#
#   compose/<target>/NN-name.ext
#             Fragments merged into ONE file at $HOME/<target>, for programs
#             that cannot read a drop-in directory. Fragments from all
#             layers are sorted by FILE NAME, so the number prefix alone
#             decides precedence; the same name in two layers is an error.
#               *.json   deep-merged with jq (later keys win, objects merge)
#               other    concatenated in order (gitconfig, ghostty, ini ...)
#             Optional markers in a target directory (any layer):
#               .mode           octal file mode for the result (e.g. 600)
#               .keep-existing  JSON only: merge on top of the current file
#                               instead of replacing it (app-written keys
#                               survive, managed keys win)
#             `${env:NAME}` placeholders are resolved from the layers'
#             secrets.env files (NAME=VALUE; `op://` values are read with the
#             1Password CLI) or, failing that, from the environment.
#
# Idempotent: unchanged files are not rewritten; prints "nothing to do"
# when everything already matches.
#
# Output: one status line plus one detail line per changed file, through
# .scripts/ui.sh.
set -eu

root=${1:?usage: apply.sh <repo-root> <layer>...}
shift
[ $# -gt 0 ] || { echo "apply.sh: no layers given" >&2; exit 2; }

# shellcheck source=.scripts/ui.sh
. "$root/.scripts/ui.sh"
ui_init apply

home=${HOME:?}
# Paths may contain spaces (macOS "Application Support"): split lists on
# newlines only.
nl='
'
IFS=$nl
layers_nl=$(printf '%s\n' "$@")
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
changed=0
failed=0
: >"$tmp/changes"

# install <src-file> <dest-path>: write only when content or mode differs
install_file() {
    src=$1 dest=$2 mode=$3
    if [ -f "$dest" ] && cmp -s "$src" "$dest"; then
        cur=$(ls -l "$dest" | cut -c2-10)
        want=$(mode_string "$mode")
        [ "$cur" = "$want" ] && return 0
        chmod "$mode" "$dest"
        printf 'mode\t%s\t%s\n' "${dest#"$home"/}" "$mode" >>"$tmp/changes"
        changed=$((changed + 1))
        return 0
    fi
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest.dotfiles-new"
    chmod "$mode" "$dest.dotfiles-new"
    mv "$dest.dotfiles-new" "$dest"
    printf 'update\t%s\t\n' "${dest#"$home"/}" >>"$tmp/changes"
    changed=$((changed + 1))
}

mode_string() {
    case $1 in
        755) echo rwxr-xr-x ;; 700) echo rwx------ ;; 644) echo rw-r--r-- ;;
        600) echo rw------- ;; 640) echo rw-r----- ;; *) echo "?" ;;
    esac
}

# ------------------------------------------------------------------ home/
for layer in "$@"; do
    dir="$root/$layer/home"
    [ -d "$dir" ] || continue
    (cd "$dir" && find . -type f) | sed 's|^\./||' | sort > "$tmp/list"
    while IFS= read -r rel; do
        src="$dir/$rel"
        if [ -x "$src" ]; then mode=755; else mode=644; fi
        case $rel in
            *.tmpl)
                rel=${rel%.tmpl}
                # @HOME@ is the only substitution; | cannot appear in $HOME
                sed "s|@HOME@|$home|g" "$src" > "$tmp/rendered"
                src="$tmp/rendered"
                ;;
        esac
        install_file "$src" "$home/$rel" "$mode"
    done < "$tmp/list"
done

# --------------------------------------------------------------- compose/
: > "$tmp/fragments"
for layer in "$@"; do
    dir="$root/$layer/compose"
    [ -d "$dir" ] || continue
    (cd "$dir" && find . -type f ! -name '.*') | sed 's|^\./||' | while IFS= read -r rel; do
        printf '%s\t%s\t%s\n' "$(dirname "$rel")" "$(basename "$rel")" "$dir/$rel"
    done >> "$tmp/fragments"
done

secret_value() {
    name=$1
    for layer in $layers_nl; do
        f="$root/$layer/secrets.env"
        [ -f "$f" ] || continue
        line=$(grep -E "^${name}=" "$f" | tail -n1 || true)
        [ -n "$line" ] || continue
        value=${line#*=}
        value=${value#\"}; value=${value%\"}
        case $value in
            op://*)
                command -v op >/dev/null 2>&1 || { echo "op CLI not found (needed for $name)" >&2; return 1; }
                # macOS 27 blocks op from reading the desktop app's settings
                # unless biometric unlock is forced on
                OP_BIOMETRIC_UNLOCK_ENABLED=true op read "$value" || return 1
                return 0
                ;;
            *) printf '%s' "$value"; return 0 ;;
        esac
    done
    eval "v=\${$name-}"
    if [ -n "$v" ]; then printf '%s' "$v"; return 0; fi
    echo "secret $name: not in any secrets.env and not set in the environment" >&2
    return 1
}
cut -f1 "$tmp/fragments" | sort -u > "$tmp/targets"
while IFS= read -r target; do
    [ -n "$target" ] || continue
    awk -F'\t' -v t="$target" '$1 == t' "$tmp/fragments" \
        | sort -t "$(printf '\t')" -k2,2 > "$tmp/frags"
    dups=$(cut -f2 "$tmp/frags" | uniq -d)
    if [ -n "$dups" ]; then
        echo "ERROR ~/$target: fragment name used by more than one layer: $dups" >&2
        failed=1
        continue
    fi
    files=$(cut -f3 "$tmp/frags")
    dest="$home/$target"
    mode=644 keep=0 json=0 other=0
    for layer in "$@"; do
        m="$root/$layer/compose/$target"
        [ -f "$m/.mode" ] && mode=$(tr -d ' \n' < "$m/.mode")
        [ -f "$m/.keep-existing" ] && keep=1
    done
    for f in $files; do
        case $f in *.json) json=1 ;; *) other=1 ;; esac
    done
    if [ $json = 1 ] && [ $other = 1 ]; then
        echo "ERROR ~/$target: mixes .json and non-.json fragments" >&2
        failed=1
        continue
    fi

    if [ $json = 1 ]; then
        base="$tmp/base.json"
        if [ $keep = 1 ] && [ -s "$dest" ]; then cp "$dest" "$base"; else echo '{}' > "$base"; fi
        # $files is newline-separated; IFS=newline keeps spaces intact
        # shellcheck disable=SC2086
        if ! jq -s 'reduce .[] as $x ({}; . * $x)' "$base" $files > "$tmp/out"; then
            echo "ERROR ~/$target: jq merge failed" >&2
            failed=1
            continue
        fi
    else
        : > "$tmp/out"
        for f in $files; do
            cat "$f" >> "$tmp/out"
            # keep fragments on separate lines even without a final newline
            [ -z "$(tail -c1 "$f")" ] || echo >> "$tmp/out"
        done
    fi

    names=$(grep -o '\${env:[A-Za-z_][A-Za-z0-9_]*}' "$tmp/out" | sed 's/^\${env://; s/}$//' | sort -u || true)
    ok=1
    for n in $names; do
        if ! val=$(secret_value "$n"); then ok=0; break; fi
        if [ $json = 1 ]; then
            jq --arg k "\${env:$n}" --arg v "$val" \
                'walk(if type == "string" then split($k) | join($v) else . end)' \
                "$tmp/out" > "$tmp/out2" && mv "$tmp/out2" "$tmp/out"
        else
            K="\${env:$n}" V="$val" awk '{
                k = ENVIRON["K"]; v = ENVIRON["V"]; out = ""
                while ((i = index($0, k)) > 0) { out = out substr($0, 1, i - 1) v; $0 = substr($0, i + length(k)) }
                print out $0 }' "$tmp/out" > "$tmp/out2" && mv "$tmp/out2" "$tmp/out"
        fi
    done
    if [ $ok = 0 ]; then
        echo "ERROR ~/$target: unresolved secret; file left unchanged" >&2
        failed=1
        continue
    fi
    install_file "$tmp/out" "$dest" "$mode"
done < "$tmp/targets"

if [ $failed = 1 ]; then
    ui_fail "finished with errors (see above)"
    exit 1
fi
if [ $changed = 0 ]; then
    ui_ok "nothing to do"
    exit 0
fi
ui_upd "$(ui_plural "$changed" file files) changed"
while IFS='	' read -r kind rel mode; do
    if [ "$kind" = mode ]; then
        ui_detail "~/$rel (mode $mode)"
    else
        ui_detail "~/$rel"
    fi
done <"$tmp/changes"
