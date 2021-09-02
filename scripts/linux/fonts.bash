#!/bin/bash
# vim:set ft=bash et sw=4:

fonts_dir="$HOME/.local/share/fonts/FiraCode"

if [ ! -d "$fonts_dir" ]; then
    mkdir -p "$fonts_dir"
fi

file_path="$fonts_dir/Fira_Code_Retina_Nerd_Font_Complete.ttf"
file_url="https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/FiraCode/Retina/complete/Fira%20Code%20Retina%20Nerd%20Font%20Complete.ttf?raw=true"

if [ ! -e "$file_path" ]; then
    download "$file_url" "$file_path"
fi

echo "fc-cache -f"

fc-cache -f
