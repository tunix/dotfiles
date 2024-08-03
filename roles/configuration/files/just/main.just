import? x'$HOME/.config/just/midas/main.just'

default:
    just --list

update-skel:
    #!/usr/bin/bash
    rsync -avz /etc/skel $HOME

install-lunarvim:
    #!/usr/bin/bash
    LV_BRANCH='release-1.4/neovim-0.9' \
        bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.4/neovim-0.9/utils/installer/install.sh) \
        -y --install-dependencies
