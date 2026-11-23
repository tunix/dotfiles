# vim: set ft=just :
# Host: penguix — Linux desktop (Bluefin/Dakota, GNOME).
# First run:  just --justfile hosts/penguix.just setup
# Afterwards: `just <recipe>` from anywhere under $HOME (see install-global).

repo_root := parent_directory(source_directory())
host_file := source_file()
layers := "common linux linux/gnome"

# list this host's recipes
default:
    @just --justfile "{{ host_file }}" --list

import "../common/recipes/main.just"
import "../linux/recipes/main.just"
import "../linux/gnome/recipes/main.just"

# Bring this machine to the repo state. Every step is idempotent.
[linux]
[group('dotfiles')]
setup: flatpak-remote brew-sync apply change-shell sysctl-ttl bashrc-dircolors bat-cache lazyvim-config dconf-apply extensions theme-sync sun-scheduler bibata aws-session-manager install-global
    @echo "Done. Log out/in (or restart GNOME Shell) so extension and dconf changes fully apply."
