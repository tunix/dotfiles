dotfiles
========

my personal dot files

## Installation

Please install `ansible` in order to proceed.

```
$ ansible-galaxy collection install community.general
$ ansible-galaxy collection install containers.podman

$ ansible-playbook penguix.yml
```

## For Pi5, the execution command is:

```
$ ansible-playbook -i pi5, pi5.yml
```

so that it connects to host without having to define an inventory.
