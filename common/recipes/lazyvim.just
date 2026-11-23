nvim_config := x'$HOME/.config/nvim'
nvim_share := x'$HOME/.local/share/nvim'
nvim_state := x'$HOME/.local/state/nvim'
nvim_cache := x'$HOME/.cache/nvim'

# installs LazyVim starter config (then the dotfiles plugin overrides)
@lazyvim-install: && lazyvim-config
    git clone https://github.com/LazyVim/starter {{ nvim_config }}
    rm -rf {{ nvim_config }}/.git
    echo "LazyVim installed. Run nvim to bootstrap plugins."

# backs up existing nvim config, data, state and cache (*.bak)
@lazyvim-backup:
    for dir in {{ nvim_config }} {{ nvim_share }} {{ nvim_state }} {{ nvim_cache }}; do \
        [ -d "$dir" ] && mv "$dir" "$dir.bak"; \
    done || true

# wipes plugins, state and cache but keeps config (fresh bootstrap on next launch)
[confirm("This will delete nvim data, state and cache. Continue?")]
@lazyvim-reset:
    rm -rf {{ nvim_share }} {{ nvim_state }} {{ nvim_cache }}

# removes LazyVim completely (config + data + state + cache)
[confirm("This will delete your entire nvim setup including config. Continue?")]
@lazyvim-remove:
    rm -rf {{ nvim_config }} {{ nvim_share }} {{ nvim_state }} {{ nvim_cache }}

# removes everything and reinstalls the starter config
@lazyvim-reinstall: lazyvim-remove lazyvim-install

# updates plugins headlessly
@lazyvim-update:
    nvim --headless "+Lazy! sync" +qa

# deploys the dotfiles plugin overrides (colorscheme, catppuccin) into an
# existing LazyVim config; skipped until lazyvim-install has created it, so
# the starter clone never finds a pre-populated ~/.config/nvim
lazyvim-config:
    #!/bin/sh
    set -eu
    dest={{ nvim_config }}/lua/plugins
    if [ ! -d "$dest" ]; then
        echo "LazyVim not installed ($dest missing); run 'just lazyvim-install' first. Nothing to do."
        exit 0
    fi
    changed=0
    for f in "{{ repo_root }}"/common/lazyvim/*.lua; do
        t="$dest/$(basename "$f")"
        if ! cmp -s "$f" "$t"; then
            cp "$f" "$t"
            echo "update $t"
            changed=1
        fi
    done
    [ "$changed" = 1 ] || echo "LazyVim overrides up to date; nothing to do."
