ssh_dir := x'$HOME/.ssh'

# creates ~/.ssh skeleton; appends Include idempotently (keeps keys + existing config)
ssh-init:
    #!/bin/sh
    set -eu
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init ssh-init
    changed=0
    mkdir -p {{ ssh_dir }}/config.d
    chmod 700 {{ ssh_dir }}
    if [ ! -f {{ ssh_dir }}/config ]; then
        printf '# vim: sw=2:ts=2:sts=2\n' >{{ ssh_dir }}/config
        changed=1
    fi
    if ! grep -qE '^[[:space:]]*Include[[:space:]]+config\.d/\*' {{ ssh_dir }}/config; then
        printf '\nInclude config.d/*\n' >>{{ ssh_dir }}/config
        ui_note "added 'Include config.d/*' to ~/.ssh/config"
        changed=1
    fi
    chmod 600 {{ ssh_dir }}/config
    if [ "$changed" = 0 ]; then
        ui_ok "~/.ssh/config already includes config.d/*"
    else
        ui_upd "~/.ssh skeleton created"
    fi

# wipes ~/.ssh completely and recreates it from scratch
[confirm("This will DELETE ~/.ssh entirely (keys included). Continue?")]
ssh-reset: && ssh-init
    #!/bin/sh
    set -eu
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init ssh-reset
    rm -rf {{ ssh_dir }}
    ui_upd "~/.ssh wiped and recreated"
