# vim: set ft=just :
# Host: mac — the work MacBook (macOS, Homebrew, work layers).
# First run:  .scripts/bootstrap-mac.sh   (installs Homebrew + just, then runs `setup`)
# Afterwards: `just <recipe>` from anywhere under $HOME (see install-global).

repo_root := parent_directory(source_directory())
host_file := source_file()
layers := "common macos work/cursor work/midas"
# One id per just invocation: every step tags its report line with it, so the
# tally at the end of `setup` counts exactly this run (see .scripts/ui.sh).
# A work recipe called below inherits it through the environment.
export DOTFILES_RUN := env_var_or_default('DOTFILES_RUN', uuid())

# list this host's recipes
default:
    @just -f "{{ host_file }}" -l

import "../common/recipes/main.just"
import "../macos/recipes/main.just"
# work is a private submodule; `import?` skips it when not checked out
import? "../work/cursor/recipes/main.just"
import? "../work/midas/recipes/main.just"

# Bring this machine to the repo state. Every step is idempotent; one line per
# step, plus the tally from .scripts/summary.sh.
[macos]
[group('dotfiles')]
setup: work-submodule brew-sync apply sysctl-ttl bashrc-dircolors bat-cache lazyvim-config aws-session-manager install-global
    #!/bin/sh
    set -eu
    # work recipes are optional imports: call them only when present, so the
    # host file still parses before the submodule is checked out
    recipes=$({{ just_executable() }} -f "{{ host_file }}" --summary)
    for r in cursor-legacy-cleanup; do
        case " $recipes " in
            *" $r "*) {{ just_executable() }} -f "{{ host_file }}" "$r" ;;
        esac
    done
    sh "{{ repo_root }}/.scripts/summary.sh"

# `setup` with every step's raw command output (DOTFILES_VERBOSE=1).
[macos]
[group('dotfiles')]
setup-verbose:
    #!/bin/sh
    set -eu
    DOTFILES_VERBOSE=1 exec {{ just_executable() }} -f "{{ host_file }}" setup

# Check out the private work submodule (needs the 1Password SSH agent).
[macos]
[group('dotfiles')]
work-submodule:
    #!/bin/sh
    set -eu
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init work-submodule
    if [ -f "{{ repo_root }}/work/midas/recipes/main.just" ]; then
        ui_ok "work submodule present"
        exit 0
    fi
    ui_run git -C "{{ repo_root }}" submodule update --init work
    ui_upd "work submodule checked out; re-run setup so its recipes are imported"
