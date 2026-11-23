# vim: set ft=just :
# Host: penguix — Linux desktop (Bluefin/Dakota, GNOME).
# First run:  just -f hosts/penguix.just setup
# Afterwards: `just <recipe>` from anywhere under $HOME (see install-global).

repo_root := parent_directory(source_directory())
host_file := source_file()
layers := "common linux linux/gnome"

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
[linux]
[group('dotfiles')]
setup: base shell desktop install-global
    @echo "Done. Log out/in (or restart GNOME Shell) so extension and dconf changes fully apply."

# App sources and packages, then the files themselves into $HOME.
[linux]
[private]
base: flatpak-remote brew-sync apply

# Login shell, kernel tweak, bash/CLI colours and the editor config.
[linux]
[private]
shell: change-shell sysctl-ttl bashrc-dircolors bat-cache lazyvim-config

# GNOME desktop: user settings, extensions, device rules, timers and apps.
[linux]
[private]
desktop: dconf-apply extensions solaar-udev theme-sync sun-scheduler bibata aws-session-manager
