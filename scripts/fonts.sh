#!/usr/bin/env bash

fonts_dir="${HOME}/.local/share/fonts/FiraCode"

if [ ! -d "${fonts_dir}" ]; then
    echo "mkdir -p $fonts_dir"

    mkdir -p "${fonts_dir}"
else
    echo "Found fonts dir $fonts_dir"
fi

file_path="$fonts_dir/Fira_Code_Retina_Nerd_Font_Complete.ttf"
file_url="https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/FiraCode/Retina/complete/Fira%20Code%20Retina%20Nerd%20Font%20Complete.ttf?raw=true"

if [ ! -e "${file_path}" ]; then
    echo "wget -O $file_path $file_url"

    wget -O "${file_path}" "${file_url}"
else
    echo "Found existing file $file_path"
fi

echo "fc-cache -f"

fc-cache -f
