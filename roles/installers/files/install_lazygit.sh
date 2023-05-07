#!/usr/bin/env bash

export ARCHITECTURE=$(uname -m)
export KERNEL=$(uname -s)
export BINARY_PATH="$HOME/.local/bin"
export DOWNLOAD_URL=$(curl -Ls https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
    | jq -r '.assets[] | select(.name | test("lazygit_.*'${KERNEL}'_'${ARCHITECTURE}'.tar.gz")) | .browser_download_url')

curl -L $DOWNLOAD_URL | tar zxvf - -C $BINARY_PATH lazygit

chmod +x $BINARY_PATH/lazygit