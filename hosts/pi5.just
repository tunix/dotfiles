# vim: set ft=just :
# Host: pi5 — Raspberry Pi 5 (Raspberry Pi OS / Debian, no Homebrew).
# First run:  hosts/pi5.sh   (installs just, then runs `setup`)
# Afterwards: `just <recipe>` from anywhere under $HOME (see install-global).

repo_root := parent_directory(source_directory())
host_file := source_file()
layers := "common linux pi"

# list this host's recipes
default:
    @just --justfile "{{ host_file }}" --list

import "../common/recipes/main.just"
import "../linux/recipes/main.just"
import "../pi/recipes/main.just"

# Bring this machine to the repo state. Every step is idempotent.
[linux]
[group('dotfiles')]
setup: apt-packages apply change-shell bashrc-dircolors bat-cache lazyvim-config install-global
