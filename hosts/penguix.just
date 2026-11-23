# vim: set ft=just :
# Host: penguix — Linux desktop (Bluefin/Dakota, GNOME).
# First run:  just -f hosts/penguix.just setup
# Afterwards: `just <recipe>` from anywhere under $HOME (see install-global).

repo_root := parent_directory(source_directory())
host_file := source_file()
layers := "common linux linux/gnome"
# One id per just invocation: every step tags its report line with it, so the
# tally at the end of `setup` counts exactly this run (see .scripts/ui.sh).
export DOTFILES_RUN := env_var_or_default('DOTFILES_RUN', uuid())

# list this host's recipes
default:
    @just -f "{{ host_file }}" -l

import "../common/recipes/main.just"
import "../linux/recipes/main.just"
import "../linux/gnome/recipes/main.just"

# Bring this machine to the repo state. Every step is idempotent.
#
# The steps are grouped into ordered phases instead of one long dependency
# line: each phase is a private recipe (hidden from `just -l`, runnable on its
# own) listing its members left to right, and `setup` lists the phases. just
# expands dependencies depth-first in order, so the effective order is
# unchanged. Add a step to the phase it belongs to, or add a phase here.
#
# Every step prints one status line (.scripts/ui.sh) and `setup` ends with the
# tally .scripts/summary.sh reads from this run's report.
[linux]
[group('dotfiles')]
setup: base shell gnome install-global
    @sh "{{ repo_root }}/.scripts/summary.sh" "log out/in (or restart GNOME Shell) for the dconf and extension changes to apply fully"

# App sources and packages, the files, then the device rules the apps need.
[linux]
[private]
base: flatpak-remote brew-sync apply solaar-udev

# Login shell, kernel tweak, bash/CLI colours, editor config, CLI plugins.
[linux]
[private]
shell: change-shell sysctl-ttl bashrc-dircolors bat-cache lazyvim-config aws-session-manager

# GNOME-only: user settings, shell extensions, colour-scheme timers, cursor.
[linux]
[private]
gnome: dconf-apply extensions theme-sync sun-scheduler bibata

# `setup` with every step's raw command output (DOTFILES_VERBOSE=1).
[linux]
[group('dotfiles')]
setup-verbose:
    #!/bin/sh
    set -eu
    DOTFILES_VERBOSE=1 exec {{ just_executable() }} -f "{{ host_file }}" setup
