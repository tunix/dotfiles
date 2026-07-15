nvim_config := x'$HOME/.config/nvim'
nvim_share := x'$HOME/.local/share/nvim'
nvim_state := x'$HOME/.local/state/nvim'
nvim_cache := x'$HOME/.cache/nvim'

# installs LazyVim starter config
@lazyvim-install:
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
