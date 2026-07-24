ssh_dir := x'$HOME/.ssh'

# creates ~/.ssh skeleton; appends Include idempotently (keeps keys + existing config)
@ssh-init:
    mkdir -p {{ ssh_dir }}/config.d
    chmod 700 {{ ssh_dir }}
    test -f {{ ssh_dir }}/config || printf '# vim: sw=2:ts=2:sts=2\n' > {{ ssh_dir }}/config
    grep -qE '^[[:space:]]*Include[[:space:]]+config\.d/\*' {{ ssh_dir }}/config || printf '\nInclude config.d/*\n' >> {{ ssh_dir }}/config
    chmod 600 {{ ssh_dir }}/config

# wipes ~/.ssh completely and recreates it from scratch
[confirm("This will DELETE ~/.ssh entirely (keys included). Continue?")]
@ssh-reset: && ssh-init
    rm -rf {{ ssh_dir }}
