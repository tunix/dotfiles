# vim: set ft=just :
# PATH lives in ~/.config/environment.d (systemd user env — shell-independent).
# Layers drop numbered files there (10-path, 15-path-brew, 90-path-system);
# user-added dirs go to 20-path-extra.conf, which is never in the repo.
env_d := x'$HOME/.config/environment.d'
extra := env_d + '/20-path-extra.conf'

# adds a dir to PATH extras (20-path-extra.conf); idempotent, ~-aware
[linux]
[positional-arguments]
add-path dir:
    #!/bin/bash
    # value starts as the literal ${PATH}: systemd-environment-d-generator
    # resolves it against the files before it (files apply alphabetically,
    # so extras follow 15-path-brew.conf and precede 90-path-system.conf)
    set -euo pipefail
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init add-path
    dir="$1"
    if [[ $dir == '~' ]]; then
        dir="$HOME"
    elif [[ $dir == '~/'* ]]; then
        dir="$HOME/${dir:2}"
    fi
    mkdir -p {{ env_d }}
    file={{ extra }}
    # seed with the literal ${PATH} — single quotes keep it unexpanded by bash
    if [[ ! -f $file ]]; then
        printf 'PATH=${PATH}\n' > "$file"
    fi
    value=$(sed -n 's/^PATH=//p' "$file")
    added=0
    # idempotent: skip if the dir is already in the value
    if [[ ":$value:" != *":$dir:"* ]]; then
        printf 'PATH=%s:%s\n' "$value" "$dir" > "$file.tmp"
        mv "$file.tmp" "$file"
        added=1
    fi
    if [[ ! -d $dir ]]; then
        ui_note "warning: $dir is not an existing directory (added anyway)"
    fi
    if [ "$added" = 1 ]; then
        ui_upd "added $dir"
    else
        ui_ok "$dir already in PATH extras"
    fi
    ui_detail "$(grep '^PATH=' "$file")"

# no re-login needed after `just apply`: sets resolved PATH in running systemd user env
[linux]
path-apply:
    #!/bin/bash
    # GUI apps + new terminals inherit it; running shells keep their old PATH
    # until restarted
    set -euo pipefail
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init path-apply
    value=$({{ just_executable() }} -f {{ justfile() }} _resolve-path)
    systemctl --user set-environment "PATH=$value"
    ui_note "running shells keep their old PATH until restarted"
    ui_upd "systemd user env PATH updated; new sessions inherit it"

# computes the final PATH like systemd-environment-d-generator would:
# apply each PATH= file in alphabetical order, replacing the `${PATH}` token
# with the value accumulated so far
[linux]
_resolve-path:
    #!/bin/bash
    set -euo pipefail
    value=
    for file in {{ env_d }}/*.conf; do
        [[ -f $file ]] || continue
        line=$(sed -n 's/^PATH=//p' "$file" | tail -n1)
        [[ -n $line ]] || continue
        # expand the ${PATH} token against the accumulated value
        value=${line/\$\{PATH\}/$value}
    done
    printf '%s\n' "$value"

# prints the resolved PATH (files in name order, like the systemd generator)
[linux]
@path-show:
    {{ just_executable() }} -f {{ justfile() }} _resolve-path
