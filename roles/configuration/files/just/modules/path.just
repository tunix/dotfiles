# PATH lives in ~/.config/environment.d (systemd user env — shell-independent)
env_d := x'$HOME/.config/environment.d'
extra := env_d + '/20-path-extra.conf'

# adds a dir to 20-path-extra.conf as `PATH=<value>:<dir>`; the value starts as
# the literal `${PATH}`, which systemd-environment-d-generator resolves against
# 10-path.conf (files apply alphabetically, so extras precede 30-path-system.conf)
[positional-arguments]
add-path dir:
    #!/bin/bash
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

# computes the final PATH like systemd-environment-d-generator would:
# apply each PATH= file in alphabetical order, replacing the `${PATH}` token
# with the value accumulated so far (missing files are skipped)
path-show:
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
