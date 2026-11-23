# vim: set ft=just :
# Host: mac — the work MacBook (macOS, Homebrew, work layers).
# First run:  .scripts/bootstrap-mac.sh   (installs Homebrew + just, then runs `setup`)
# Afterwards: `just <recipe>` from anywhere under $HOME (see install-global).

repo_root := parent_directory(source_directory())
host_file := source_file()
layers := "common macos work/cursor work/midas"

# list this host's recipes
default:
    @just -f "{{ host_file }}" -l

import "../common/recipes/main.just"
import "../macos/recipes/main.just"
# work is a private submodule; `import?` skips it when not checked out
import? "../work/cursor/recipes/main.just"
import? "../work/midas/recipes/main.just"

# Bring this machine to the repo state. Every step is idempotent.
[macos]
[group('dotfiles')]
setup: work-submodule brew-sync apply sysctl-ttl bashrc-dircolors bat-cache lazyvim-config aws-session-manager install-global
    #!/bin/sh
    set -eu
    # work recipes are optional imports: call them only when present, so the
    # host file still parses before the submodule is checked out
    recipes=$(just -f "{{ host_file }}" --summary)
    for r in cursor-legacy-cleanup; do
        case " $recipes " in
            *" $r "*) just -f "{{ host_file }}" "$r" ;;
        esac
    done

# Check out the private work submodule (needs the 1Password SSH agent).
[macos]
[group('dotfiles')]
work-submodule:
    #!/bin/sh
    set -eu
    if [ -f "{{ repo_root }}/work/midas/recipes/main.just" ]; then
        echo "work submodule present; nothing to do."
        exit 0
    fi
    git -C "{{ repo_root }}" submodule update --init work
    echo "work submodule checked out. Re-run setup so its recipes are imported."
