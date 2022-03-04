dotfiles
========

my personal dot files

## Features

All roles support Linux (Debian & RedHat based distros) & Mac.

#### Package Installation

* System76 software installation for Fedora Silverblue
* Repository management per host
* Updating/installing packages (including flatpak, ostree & homebrew) per host

#### Configuration

Includes configuration for CLI and desktop apps for both Linux & Mac.

Configures:

* some defaults (such as open command or shell)
* dir_colors
* fonts
* alacritty
* editorconfig
* fish
* git
* neovim
* ssh
* tmux
* distrobox
* desktop
  * avatar
  * dconf
  * GNOME extensions

#### Work

Executes work related tasks such as:

* Placing SSH keys
* Configuring special git configuration per directory
* Configuring k8s configuration

#### Toolbox

Creates tooling containers:

* `tools` container for general purpose CLI tools
* `document-scanner` container for scanning documents

## Installation

Please install `ansible` in order to proceed.

```
$ ansible-galaxy collection install community.general
$ ansible-galaxy collection install containers.podman

$ ansible-playbook -K -i inventory/penguix-popos main.yml
$ ansible-playbook -i inventory/penguix-popos work.yml
$ ansible-playbook -i inventory/penguix-popos toolbox.yml
```
