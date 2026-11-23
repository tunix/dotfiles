# vim: set ft=just :
# Layer deployment, validation and the home-wide justfile.

# Deploy every active layer's home/ and compose/ files into $HOME (idempotent).
[group('dotfiles')]
apply:
    @sh "{{ repo_root }}/.scripts/apply.sh" "{{ repo_root }}" {{ layers }}

# Validate the repo: layer rules, fragment numbering, every host file parses.
[group('dotfiles')]
check:
    @bash "{{ repo_root }}/.scripts/check.sh" "{{ repo_root }}"

# Make this host's recipes callable from anywhere under $HOME without -g:
# writes a one-line ~/.justfile that imports the host file (no copies, so
# new recipes show up immediately). The same line goes to
# ~/.config/just/justfile for `just -g` outside $HOME. Re-run only when the
# host file changes or the repo moves.
[group('dotfiles')]
install-global:
    #!/bin/sh
    set -eu
    line="import '{{ host_file }}'"
    marker="# managed by dotfiles (just install-global)"
    for f in "$HOME/.justfile" "$HOME/.config/just/justfile"; do
        want=$(printf '%s\n%s\n' "$marker" "$line")
        if [ -f "$f" ] && [ "$(cat "$f")" = "$want" ]; then
            echo "${f#"$HOME"/} already imports {{ host_file }}; nothing to do."
            continue
        fi
        if [ -f "$f" ] && ! grep -qF "$marker" "$f"; then
            mv "$f" "$f.pre-dotfiles"
            echo "kept the previous ${f#"$HOME"/} as ${f#"$HOME"/}.pre-dotfiles"
        fi
        mkdir -p "$(dirname "$f")"
        printf '%s\n' "$want" > "$f"
        echo "${f#"$HOME"/} -> {{ host_file }}"
    done
