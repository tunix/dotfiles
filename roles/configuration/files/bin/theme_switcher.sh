#!/bin/sh

variant="$1"

if [[ "$variant" == "dark" ]]; then
    sed -i 's/colors: \*light/colors: \*dark/g' ~/.config/alacritty/alacritty.yml
    # sed -i 's/colorscheme nord-light$/colorscheme nord/g' ~/.config/nvim/colorize.vim
else
    sed -i 's/colors: \*dark/colors: \*light/g' ~/.config/alacritty/alacritty.yml
    # sed -i 's/colorscheme nord$/colorscheme nord-light/g' ~/.config/nvim/colorize.vim
fi
