nvim_config := x'$HOME/.config/nvim'
nvim_share := x'$HOME/.local/share/nvim'
nvim_state := x'$HOME/.local/state/nvim'
nvim_cache := x'$HOME/.cache/nvim'

# installs LazyVim starter config (then the dotfiles plugin overrides)
lazyvim-install: && lazyvim-config
    #!/bin/sh
    set -eu
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init lazyvim-install
    ui_run git clone https://github.com/LazyVim/starter {{ nvim_config }}
    rm -rf {{ nvim_config }}/.git
    ui_upd "LazyVim starter cloned; run nvim to bootstrap plugins"

# backs up existing nvim config, data, state and cache (*.bak)
lazyvim-backup:
    #!/bin/sh
    set -eu
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init lazyvim-backup
    n=0
    for dir in {{ nvim_config }} {{ nvim_share }} {{ nvim_state }} {{ nvim_cache }}; do
        if [ -d "$dir" ]; then
            mv "$dir" "$dir.bak"
            ui_note "$dir -> $dir.bak"
            n=$((n + 1))
        fi
    done
    if [ "$n" = 0 ]; then
        ui_ok "nothing to back up"
    else
        ui_upd "$n directories moved aside (*.bak)"
    fi

# wipes plugins, state and cache but keeps config (fresh bootstrap on next launch)
[confirm("This will delete nvim data, state and cache. Continue?")]
lazyvim-reset:
    #!/bin/sh
    set -eu
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init lazyvim-reset
    rm -rf {{ nvim_share }} {{ nvim_state }} {{ nvim_cache }}
    ui_upd "nvim data, state and cache removed"

# removes LazyVim completely (config + data + state + cache)
[confirm("This will delete your entire nvim setup including config. Continue?")]
lazyvim-remove:
    #!/bin/sh
    set -eu
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init lazyvim-remove
    rm -rf {{ nvim_config }} {{ nvim_share }} {{ nvim_state }} {{ nvim_cache }}
    ui_upd "nvim config, data, state and cache removed"

# removes everything and reinstalls the starter config
lazyvim-reinstall: lazyvim-remove lazyvim-install

# updates plugins headlessly
lazyvim-update:
    #!/bin/sh
    set -eu
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init lazyvim-update
    ui_run nvim --headless "+Lazy! sync" +qa
    ui_upd "plugins synced"

# deploys the dotfiles plugin overrides (colorscheme, catppuccin) into an
# existing LazyVim config; skipped until lazyvim-install has created it, so
# the starter clone never finds a pre-populated ~/.config/nvim
lazyvim-config:
    #!/bin/sh
    set -eu
    . "{{ repo_root }}/.scripts/ui.sh"
    ui_init lazyvim-config
    dest={{ nvim_config }}/lua/plugins
    if [ ! -d "$dest" ]; then
        ui_skip "LazyVim not installed; run 'just lazyvim-install' first"
        exit 0
    fi
    changed=0
    for f in "{{ repo_root }}"/common/lazyvim/*.lua; do
        t="$dest/$(basename "$f")"
        if ! cmp -s "$f" "$t"; then
            cp "$f" "$t"
            ui_note "~/.config/nvim/lua/plugins/$(basename "$f")"
            changed=$((changed + 1))
        fi
    done
    if [ "$changed" = 0 ]; then
        ui_ok "plugin overrides up to date"
    else
        ui_upd "$(ui_plural "$changed" plugin file plugin files) deployed"
    fi
