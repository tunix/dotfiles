# PATH lives in ~/.config/environment.d (systemd user env — shell-independent)
env_d := x'$HOME/.config/environment.d'
extra := env_d + '/20-path-extra.conf'

# adds a dir to PATH extras (20-path-extra.conf); idempotent, ~-aware
[positional-arguments]
add-path dir:
    #!/bin/bash
    # value starts as the literal ${PATH}: systemd-environment-d-generator
    # resolves it against 10-path.conf (files apply alphabetically, so extras
    # precede 30-path-system.conf)
    set -euo pipefail
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
    # idempotent: skip if the dir is already in the value
    if [[ ":$value:" != *":$dir:"* ]]; then
        printf 'PATH=%s:%s\n' "$value" "$dir" > "$file.tmp"
        mv "$file.tmp" "$file"
    fi
    if [[ ! -d $dir ]]; then
        echo "warning: $dir is not an existing directory (added anyway)" >&2
    fi
    grep '^PATH=' "$file"

# no re-login needed after ansible-playbook: sets resolved PATH in running systemd user env
path-apply:
    #!/bin/bash
    # GUI apps + new terminals inherit it; running shells keep their old PATH
    # until restarted
    #!/bin/bash
    set -euo pipefail
    value=$({{ just_executable() }} --justfile {{ justfile() }} _resolve-path)
    systemctl --user set-environment "PATH=$value"
    echo "systemd user env PATH updated; new sessions inherit it"
    echo "note: running shells keep their old PATH until restarted"

# computes the final PATH like systemd-environment-d-generator would:
# apply each PATH= file in alphabetical order, replacing the `${PATH}` token
# with the value accumulated so far (missing files are skipped)
_resolve-path:
    #!/bin/bash
    set -euo pipefail
    value=
    for name in 10-path.conf 20-path-extra.conf 30-path-system.conf; do
        file={{ env_d }}/$name
        [[ -f $file ]] || continue
        line=$(sed -n 's/^PATH=//p' "$file" | tail -n1)
        [[ -n $line ]] || continue
        # expand the ${PATH} token against the accumulated value
        value=${line/\$\{PATH\}/$value}
    done
    printf '%s\n' "$value"

# prints the resolved PATH (10 -> 20 -> 30, like the systemd generator)
@path-show:
    {{ just_executable() }} --justfile {{ justfile() }} _resolve-path
