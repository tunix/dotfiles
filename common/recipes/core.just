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
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init install-global
    line="import '{{ host_file }}'"
    marker="# managed by dotfiles (just install-global)"
    written=0
    for f in "$HOME/.justfile" "$HOME/.config/just/justfile"; do
        want=$(printf '%s\n%s\n' "$marker" "$line")
        if [ -f "$f" ] && [ "$(cat "$f")" = "$want" ]; then continue; fi
        if [ -f "$f" ] && ! grep -qF "$marker" "$f"; then
            mv "$f" "$f.pre-dotfiles"
            ui_note "kept the previous ~/${f#"$HOME"/} as ~/${f#"$HOME"/}.pre-dotfiles"
        fi
        mkdir -p "$(dirname "$f")"
        printf '%s\n' "$want" >"$f"
        ui_note "~/${f#"$HOME"/} -> {{ host_file }}"
        written=$((written + 1))
    done
    if [ "$written" = 0 ]; then
        ui_ok "~/.justfile already imports the host file"
    else
        ui_upd "$(ui_plural "$written" file files) written"
    fi
